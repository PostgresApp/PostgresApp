// PostgresServer.m
//
// Created by Mattt Thompson (http://mattt.me/)
// Copyright (c) 2012 Heroku (http://heroku.com/)
// 
// Portions Copyright (c) 1996-2012, The PostgreSQL Global Development Group
// Portions Copyright (c) 1994, The Regents of the University of California
//
// Permission to use, copy, modify, and distribute this software and its
// documentation for any purpose, without fee, and without a written agreement
// is hereby granted, provided that the above copyright notice and this
// paragraph and the following two paragraphs appear in all copies.
//
// IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
// DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
// LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
// EVEN IF THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
//
// THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
// FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN
// "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATIONS TO
// PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

#import <xpc/xpc.h>
#import "PostgresServer.h"
#import "NSFileManager+DirectoryLocations.h"
#import "RecoveryAttempter.h"

#define xstr(a) str(a)
#define str(a) #a

static NSString * PGNormalizedVersionStringFromString(NSString *version) {
    if (!version) {
        return nil;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:version];
    [scanner setCharactersToBeSkipped:[NSCharacterSet punctuationCharacterSet]];
    
    NSString *major, *minor, *tiny = nil;
    [scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&major];
    [scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&minor];
    [scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&tiny];

    return [[NSArray arrayWithObjects:(major ?: @"0"), (minor ?: @"0"), nil] componentsJoinedByString:@"."];
}

@interface PostgresServer()
@property BOOL isRunning;
@property NSUInteger port;
@end

@implementation PostgresServer

+(NSString*)standardDatabaseDirectory {
	return [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingFormat:@"/var-%s", xstr(PG_MAJOR_VERSION)];
}

+(PostgresDataDirectoryStatus)statusOfDataDirectory:(NSString*)dir {
	NSString *versionFilePath = [dir stringByAppendingPathComponent:@"PG_VERSION"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:versionFilePath]) {
		return PostgresDataDirectoryEmpty;
	}
	
    NSString *dataDirectoryVersion = PGNormalizedVersionStringFromString([NSString stringWithContentsOfFile:versionFilePath encoding:NSUTF8StringEncoding error:nil]);
    NSString *includedVersion = PGNormalizedVersionStringFromString([NSString stringWithUTF8String:xstr(PG_VERSION)]);

	if ([includedVersion isEqual:dataDirectoryVersion]) {
		return PostgresDataDirectoryCompatible;
	}
	
	return PostgresDataDirectoryIncompatible;
}

+(NSString*)existingDatabaseDirectory {
	// This function tries to locate existing data directories with the same version
	// It returns the first matching data directory
	NSArray *applicationSupportDirectories = @[
											   [[NSFileManager defaultManager] applicationSupportDirectory],
											   [NSHomeDirectory() stringByAppendingString:@"/Library/Application Support/Postgres93"],
											   [NSHomeDirectory() stringByAppendingString:@"/Library/Containers/com.heroku.Postgres/Data/Library/Application Support/Postgres"]
											   ];
	NSArray *dataDirNames = @[
							  @"var",
							  [NSString stringWithFormat:@"var-%s",xstr(PG_MAJOR_VERSION)]
							  ];
	for (NSString *applicationSupportDirectory in applicationSupportDirectories) {
		for (NSString *dataDirName in dataDirNames) {
			NSString *dataDirectoryPath = [applicationSupportDirectory stringByAppendingPathComponent:dataDirName];
			PostgresDataDirectoryStatus status = [self statusOfDataDirectory:dataDirectoryPath];
			if (status == PostgresDataDirectoryCompatible) {
				return dataDirectoryPath;
			}
		}
	}
	return nil;
}

+(NSString*)dataDirectoryPreferenceKey {
	return [[NSString stringWithFormat:@"%@%s", kPostgresDataDirectoryPreferenceKey, xstr(PG_MAJOR_VERSION)] stringByReplacingOccurrencesOfString:@"." withString:@""];
}

+(PostgresServer *)defaultServer {
    static PostgresServer *_sharedServer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		NSString *binDirectory = [[NSBundle mainBundle].bundlePath stringByAppendingFormat:@"/Contents/Versions/%s/bin",xstr(PG_MAJOR_VERSION)];
		NSString *databaseDirectory = [[NSUserDefaults standardUserDefaults] stringForKey:[PostgresServer dataDirectoryPreferenceKey]];
		if (!databaseDirectory || [self statusOfDataDirectory:databaseDirectory] == PostgresDataDirectoryIncompatible) {
			databaseDirectory = [self existingDatabaseDirectory];
		}
		if (!databaseDirectory) {
			databaseDirectory = [self standardDatabaseDirectory];
		}
		[[NSUserDefaults standardUserDefaults] setObject:databaseDirectory forKey:[PostgresServer dataDirectoryPreferenceKey]];
        _sharedServer = [[PostgresServer alloc] initWithExecutablesDirectory:binDirectory databaseDirectory:databaseDirectory];
    });
    
    return _sharedServer;
}

- (id)initWithExecutablesDirectory:(NSString *)executablesDirectory
                 databaseDirectory:(NSString *)databaseDirectory
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _binPath = executablesDirectory;
    _varPath = databaseDirectory;
    _port    = getenv("PGPORT") ? atol(getenv("PGPORT")) : kPostgresAppDefaultPort;
   
    NSString *conf = [_varPath stringByAppendingPathComponent:@"postgresql.conf"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:conf]) {
        const char *t = [[NSString stringWithContentsOfFile:conf encoding:NSUTF8StringEncoding error:nil] UTF8String];
        for (int i = 0; t[i]; i++) {
            if (t[i] == '#')
                while (t[i] != '\n' && t[i]) i++;
            else if (strncmp(t + i, "port ", 5) == 0) {
                if (sscanf(t + i + 5, "%*s %ld", &_port) == 1)
                    break;
            }
        }
    }
	
    return self;
}

#pragma mark - Asynchronous Server Control Methods

- (void)startWithCompletionHandler:(PostgresServerControlCompletionHandler)completionBlock;
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSError *error = nil;
		PostgresDataDirectoryStatus dataDirStatus = [PostgresServer statusOfDataDirectory:_varPath];
		
		if (dataDirStatus==PostgresDataDirectoryEmpty) {
			BOOL serverDidInit = [self initDatabaseWithError:&error];
			if (!serverDidInit) {
				if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(NO, error); });
				return;
			}
			
			BOOL serverDidStart = [self startServerWithError:&error];
			if (!serverDidStart) {
				if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(NO, error); });
				return;
			}
			
			BOOL createdUserDatabase = [self createUserDatabaseWithError:&error];
			if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(createdUserDatabase, error); });
		}
		else if (dataDirStatus==PostgresDataDirectoryCompatible) {
			BOOL serverDidStart = [self startServerWithError:&error];
			if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(serverDidStart, error); });
		}
		else {
			if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(NO, nil); });
		}
		
	});
}

- (void)stopWithCompletionHandler:(PostgresServerControlCompletionHandler)completionBlock;
{
	NSError *error = nil;
	BOOL success = [self stopServerWithError:&error];
	if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(success, error); });
}

#pragma mark - Synchronous Server Control Methods

-(PostgresServerStatus)serverStatus {
	NSTask *psqlTask = [[NSTask alloc] init];
	psqlTask.launchPath = [self.binPath stringByAppendingPathComponent:@"psql"];
	psqlTask.arguments = @[
						   [NSString stringWithFormat:@"-p%u", (unsigned)self.port],
						   @"-A",
						   @"-q",
						   @"-t",
						   @"-c", @"SHOW data_directory;",
						   @"postgres"
						   ];
	NSPipe *outPipe = [[NSPipe alloc] init];
	psqlTask.standardOutput = outPipe;
	
	[psqlTask launch];
	NSString *taskOutput = [[NSString alloc] initWithData:[[outPipe fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	[psqlTask waitUntilExit];
	
	NSString *expectedDataDirectory = self.varPath;
	NSString *actualDataDirectory = taskOutput.length>1 ? [taskOutput substringToIndex:taskOutput.length-1] : nil;
	
	switch(psqlTask.terminationStatus) {
		case 0:
			if (strcmp(actualDataDirectory.fileSystemRepresentation, expectedDataDirectory.fileSystemRepresentation)==0) {
				self.isRunning = YES;
				return PostgresServerRunning;
			} else {
				self.isRunning = NO;
				return PostgresServerWrongDataDirectory;
			}
		case 2:
			self.isRunning = NO;
			return PostgresServerUnreachable;
		default:
			self.isRunning = NO;
			return PostgresServerStatusError;
	}
}

-(BOOL)startServerWithError:(NSError**)error {
	NSTask *controlTask = [[NSTask alloc] init];
	controlTask.launchPath = [self.binPath stringByAppendingPathComponent:@"pg_ctl"];
	controlTask.arguments = @[
		/* control command          */ @"start",
		/* data directory           */ @"-D", self.varPath,
		/* wait for server to start */ @"-w",
		/* server log file          */ @"-l", self.logfilePath
	];
	controlTask.standardError = [[NSPipe alloc] init];
	[controlTask launch];
	NSString *controlTaskError = [[NSString alloc] initWithData:[[controlTask.standardError fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	[controlTask waitUntilExit];
	
	if (controlTask.terminationStatus != 0 && error) {
		NSMutableDictionary *errorUserInfo = [[NSMutableDictionary alloc] init];
		errorUserInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Could not start PostgreSQL server.",nil);
		errorUserInfo[NSLocalizedRecoverySuggestionErrorKey] = controlTaskError;
		errorUserInfo[NSLocalizedRecoveryOptionsErrorKey] = @[@"OK", @"Open Server Log"];
		errorUserInfo[NSRecoveryAttempterErrorKey] = [[RecoveryAttempter alloc] init];
		errorUserInfo[@"ServerLogRecoveryOptionIndex"] = @1;
		errorUserInfo[@"ServerLogPath"] = self.logfilePath;
		*error = [NSError errorWithDomain:@"com.postgresapp.Postgres.pg_ctl" code:controlTask.terminationStatus userInfo:errorUserInfo];
	}

	if (controlTask.terminationStatus == 0) {
		self.isRunning = YES;
	}
	
	return controlTask.terminationStatus == 0;
}

-(BOOL)stopServerWithError:(NSError**)error {
	NSTask *controlTask = [[NSTask alloc] init];
	controlTask.launchPath = [self.binPath stringByAppendingPathComponent:@"pg_ctl"];
	controlTask.arguments = @[
		/* control command         */ @"stop",
		/* fast mode (don't wait for clients to disconnect) */ @"-m", @"f",
		/* data directory          */ @"-D", self.varPath,
		/* wait for server to stop */ @"-w",
	];
	controlTask.standardError = [[NSPipe alloc] init];
	[controlTask launch];
	NSString *controlTaskError = [[NSString alloc] initWithData:[[controlTask.standardError fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	[controlTask waitUntilExit];
	
	if (controlTask.terminationStatus != 0 && error) {
		NSMutableDictionary *errorUserInfo = [[NSMutableDictionary alloc] init];
		errorUserInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Could not stop PostgreSQL server.",nil);
		errorUserInfo[NSLocalizedRecoverySuggestionErrorKey] = controlTaskError;
		errorUserInfo[NSLocalizedRecoveryOptionsErrorKey] = @[@"OK", @"Open Server Log"];
		errorUserInfo[NSRecoveryAttempterErrorKey] = [[RecoveryAttempter alloc] init];
		errorUserInfo[@"ServerLogRecoveryOptionIndex"] = @1;
		errorUserInfo[@"ServerLogPath"] = self.logfilePath;
		*error = [NSError errorWithDomain:@"com.postgresapp.Postgres.pg_ctl" code:controlTask.terminationStatus userInfo:errorUserInfo];
	}
	
	if (controlTask.terminationStatus == 0) {
		self.isRunning = NO;
	}
	
	return controlTask.terminationStatus == 0;
}

-(BOOL)initDatabaseWithError:(NSError**)error {
	NSTask *initdbTask = [[NSTask alloc] init];
	initdbTask.launchPath = [self.binPath stringByAppendingPathComponent:@"initdb"];
	initdbTask.arguments = @[
		/* data directory */ @"-D", self.varPath,
		/* encoding       */ @"-EUTF-8",
		/* locale         */ [NSString stringWithFormat:@"--locale=%@_%@.UTF-8", [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode], [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]]
	];
	initdbTask.standardError = [[NSPipe alloc] init];
	[initdbTask launch];
	NSString *initdbTaskError = [[NSString alloc] initWithData:[[initdbTask.standardError fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	[initdbTask waitUntilExit];
	
	if (initdbTask.terminationStatus != 0 && error) {
		NSMutableDictionary *errorUserInfo = [[NSMutableDictionary alloc] init];
		errorUserInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Could not initialize database cluster.",nil);
		errorUserInfo[NSLocalizedRecoverySuggestionErrorKey] = initdbTaskError;
		*error = [NSError errorWithDomain:@"com.postgresapp.Postgres.initdb" code:initdbTask.terminationStatus userInfo:errorUserInfo];
	}
	
	return initdbTask.terminationStatus == 0;
}

-(BOOL)createUserDatabaseWithError:(NSError**)error {
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = [self.binPath stringByAppendingPathComponent:@"createdb"];
	task.arguments = @[ @"-p", @(self.port).stringValue, NSUserName() ];
	task.standardError = [[NSPipe alloc] init];
	[task launch];
	NSString *taskError = [[NSString alloc] initWithData:[[task.standardError fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	[task waitUntilExit];
	
	if (task.terminationStatus != 0 && error) {
		NSMutableDictionary *errorUserInfo = [[NSMutableDictionary alloc] init];
		errorUserInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Could not create user database.",nil);
		errorUserInfo[NSLocalizedRecoverySuggestionErrorKey] = taskError;
		errorUserInfo[NSLocalizedRecoveryOptionsErrorKey] = @[@"OK", @"Open Server Log"];
		errorUserInfo[NSRecoveryAttempterErrorKey] = [[RecoveryAttempter alloc] init];
		errorUserInfo[@"ServerLogRecoveryOptionIndex"] = @1;
		errorUserInfo[@"ServerLogPath"] = self.logfilePath;
		*error = [NSError errorWithDomain:@"com.postgresapp.Postgres.createdb" code:task.terminationStatus userInfo:errorUserInfo];
	}
	
	return task.terminationStatus == 0;
}

-(NSString *)logfilePath {
	return [self.varPath stringByAppendingPathComponent:@"postgres-server.log"];
}

@end
