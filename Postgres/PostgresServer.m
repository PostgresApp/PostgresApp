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


#import "PostgresServer.h"
#import "RecoveryAttempter.h"
#import <libpq-fe.h>


@interface PostgresServer()
@property BOOL isBusy;
@property (nonatomic) BOOL isRunning;
@end



@implementation PostgresServer

- (id)init {
	NSLog(@"%@: call -initWithName instead of -init", self.class.description);
	return nil;
}

- (id)initWithName:(NSString *)name version:(NSString *)version port:(NSUInteger)port varPath:(NSString *)varPath {
	self = [super init];
	if (self) {
		self.name = name;
		self.version = version;
		self.port = port;
		self.binPath = [BUNDLE_PATH stringByAppendingFormat:@"/Contents/Versions/%@/bin", self.version];
		self.varPath = varPath;
		self.runAtStartup = NO;
		self.stopAtQuit = YES;
		
		NSString *conf = [self.varPath stringByAppendingPathComponent:@"postgresql.conf"];
		if ([[NSFileManager defaultManager] fileExistsAtPath:conf]) {
			const char *t = [[NSString stringWithContentsOfFile:conf encoding:NSUTF8StringEncoding error:nil] UTF8String];
			for (int i = 0; t[i]; i++) {
				if (t[i] == '#')
					while (t[i] != '\n' && t[i]) i++;
				else if (strncmp(t+i, "port ", 5) == 0) {
					if (sscanf(t+i+5, "%*s %ld", &_port) == 1)
						break;
				}
			}
		}
		
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [self initWithName:[coder decodeObjectForKey:@"name"]
					  version:[coder decodeObjectForKey:@"version"]
						 port:[coder decodeIntForKey:@"port"]
					  varPath:[coder decodeObjectForKey:@"varPath"]
			];
	
	if (self) {
		self.binPath = [coder decodeObjectForKey:@"binPath"];
		self.runAtStartup = [coder decodeBoolForKey:@"runAtStartup"];
		self.stopAtQuit = [coder decodeBoolForKey:@"stopAtQuit"];
	}
	return self;
}


- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.name forKey:@"name"];
	[coder encodeObject:self.version forKey:@"version"];
	[coder encodeInt:(unsigned)self.port forKey:@"port"];
	[coder encodeObject:self.binPath forKey:@"binPath"];
	[coder encodeObject:self.varPath forKey:@"varPath"];
	[coder encodeBool:self.runAtStartup forKey:@"runAtStartup"];
	[coder encodeBool:self.stopAtQuit forKey:@"stopAtQuit"];
}



#pragma mark - Async server control methods

- (void)startWithCompletionHandler:(PostgresServerControlCompletionHandler)completionBlock {
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self setIsBusyOnMainThread:YES];
		
		NSError *error = nil;
		PostgresDataDirectoryStatus dataDirStatus = [self statusOfDataDirectory:self.varPath error:&error];
		
		if (dataDirStatus == PostgresDataDirectoryEmpty) {
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
			
			BOOL createdUser = [self createUserWithError:&error];
			if (!createdUser) {
				if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(NO, error); });
				return;
			}
			
			BOOL createdUserDatabase = [self createUserDatabaseWithError:&error];
			if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(createdUserDatabase, error); });
		}
		else if (dataDirStatus == PostgresDataDirectoryCompatible) {
			BOOL serverDidStart = [self startServerWithError:&error];
			if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(serverDidStart, error); });
		}
		else {
			if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(NO, error); });
		}
		
		[self setIsBusyOnMainThread:NO];
	});
}

- (void)stopWithCompletionHandler:(PostgresServerControlCompletionHandler)completionBlock {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self setIsBusyOnMainThread:YES];
		
		NSError *error = nil;
		BOOL success = [self stopServerWithError:&error];
		if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(success, error); });
		
		[self setIsBusyOnMainThread:NO];
	});
}




#pragma mark - Sync server control methods

- (PostgresDataDirectoryStatus)statusOfDataDirectory:(NSString *)dir error:(NSError **)outError {
	if (![[NSFileManager defaultManager] fileExistsAtPath:[dir stringByAppendingPathComponent:@"PG_VERSION"]]) {
		return PostgresDataDirectoryEmpty;
	}
	return PostgresDataDirectoryCompatible;
}

- (PostgresServerStatus)serverStatus {
	if (! [[NSFileManager defaultManager] fileExistsAtPath:self.binPath]) {
		return PostgresServerStatusNoBinDir;
	}
	
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = [self.binPath stringByAppendingPathComponent:@"psql"];
	task.arguments = @[
						   [NSString stringWithFormat:@"-p%lu", self.port],
						   @"-A",
						   @"-q",
						   @"-t",
						   @"-c", @"SHOW data_directory;",
						   @"postgres"
	];
	
	NSPipe *outPipe = [[NSPipe alloc] init];
	task.standardOutput = outPipe;
	task.standardError = [[NSPipe alloc] init];
	
	[task launch];
	NSString *taskOutput = [[NSString alloc] initWithData:[[outPipe fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	[task waitUntilExit];
	
	NSString *expectedDataDirectory = self.varPath;
	NSString *actualDataDirectory = taskOutput.length>1 ? [taskOutput substringToIndex:taskOutput.length-1] : nil;
	
	switch(task.terminationStatus) {
		case 0:
			if (strcmp(actualDataDirectory.fileSystemRepresentation, expectedDataDirectory.fileSystemRepresentation) == 0) {
				[self setIsRunningOnMainThread:YES];
				return PostgresServerRunning;
			} else {
				[self setIsRunningOnMainThread:NO];
				return PostgresServerWrongDataDirectory;
			}
		case 2:
			[self setIsRunningOnMainThread:NO];
			return PostgresServerUnreachable;
		default:
			[self setIsRunningOnMainThread:NO];
			return PostgresServerStatusError;
	}
}

- (BOOL)startServerWithError:(NSError **)error {
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = [self.binPath stringByAppendingPathComponent:@"pg_ctl"];
	task.arguments = @[
		/* control command          */ @"start",
		/* data directory           */ @"-D", self.varPath,
		/* wait for server to start */ @"-w",
		/* server log file          */ @"-l", self.logfilePath,
		/* allow overriding port    */ @"-o", [NSString stringWithFormat:@"-p %lu", self.port]
	];
	
	task.standardOutput = [[NSPipe alloc] init];
	task.standardError = [[NSPipe alloc] init];
	[task launch];
	NSString *controlTaskError = [[NSString alloc] initWithData:[[task.standardError fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	[task waitUntilExit];
	
	if (task.terminationStatus != 0 && error) {
		NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
		userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Could not start PostgreSQL server.",nil);
		userInfo[NSLocalizedRecoverySuggestionErrorKey] = controlTaskError;
		userInfo[NSLocalizedRecoveryOptionsErrorKey] = @[@"OK", @"Open Server Log"];
		userInfo[NSRecoveryAttempterErrorKey] = [[RecoveryAttempter alloc] init];
		userInfo[@"ServerLogRecoveryOptionIndex"] = @1;
		userInfo[@"ServerLogPath"] = self.logfilePath;
		*error = [NSError errorWithDomain:@"com.postgresapp.Postgres.pg_ctl" code:task.terminationStatus userInfo:userInfo];
	}

	if (task.terminationStatus == 0) {
		[self setIsRunningOnMainThread:YES];
	}
	
	return task.terminationStatus == 0;
}

- (BOOL)stopServerWithError:(NSError **)error {
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = [self.binPath stringByAppendingPathComponent:@"pg_ctl"];
	task.arguments = @[
		/* control command         */ @"stop",
		/* fast mode               */ @"-m", @"f",
		/* data directory          */ @"-D", self.varPath,
		/* wait for server to stop */ @"-w",
	];
	
	task.standardOutput = [[NSPipe alloc] init];
	task.standardError = [[NSPipe alloc] init];
	[task launch];
	NSString *controlTaskError = [[NSString alloc] initWithData:[[task.standardError fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	[task waitUntilExit];
	
	if (task.terminationStatus != 0 && error) {
		NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
		userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Could not stop PostgreSQL server.",nil);
		userInfo[NSLocalizedRecoverySuggestionErrorKey] = controlTaskError;
		userInfo[NSLocalizedRecoveryOptionsErrorKey] = @[@"OK", @"Open Server Log"];
		userInfo[NSRecoveryAttempterErrorKey] = [[RecoveryAttempter alloc] init];
		userInfo[@"ServerLogRecoveryOptionIndex"] = @1;
		userInfo[@"ServerLogPath"] = self.logfilePath;
		*error = [NSError errorWithDomain:@"com.postgresapp.Postgres.pg_ctl" code:task.terminationStatus userInfo:userInfo];
	}
	
	if (task.terminationStatus == 0) {
		[self setIsRunningOnMainThread:NO];
	}
	
	return task.terminationStatus == 0;
}

- (BOOL)initDatabaseWithError:(NSError **)error {
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = [self.binPath stringByAppendingPathComponent:@"initdb"];
	task.arguments = @[
		/* data directory */ @"-D", self.varPath,
		/* superuser name */ @"-U", @"postgres",
		/* encoding       */ @"--encoding=UTF-8",
		/* locale         */ @"--locale=en_US.UTF-8"
	];
	
	task.standardOutput = [[NSPipe alloc] init];
	task.standardError = [[NSPipe alloc] init];
	[task launch];
	NSString *initdbTaskError = [[NSString alloc] initWithData:[[task.standardError fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	[task waitUntilExit];
	
	if (task.terminationStatus != 0 && error) {
		NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
		userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Could not initialize database cluster.",nil);
		userInfo[NSLocalizedRecoverySuggestionErrorKey] = initdbTaskError;
		*error = [NSError errorWithDomain:@"com.postgresapp.Postgres.initdb" code:task.terminationStatus userInfo:userInfo];
	}
	
	return task.terminationStatus == 0;
}

- (BOOL)createUserWithError:(NSError **)error {
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = [self.binPath stringByAppendingPathComponent:@"createuser"];
	task.arguments = @[
					   @"-U", @"postgres",
					   @"-p", @(self.port).stringValue,
					   @"--superuser",
					   NSUserName()
	];
	
	task.standardOutput = [[NSPipe alloc] init];
	task.standardError = [[NSPipe alloc] init];
	[task launch];
	NSString *taskError = [[NSString alloc] initWithData:[[task.standardError fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	[task waitUntilExit];
	
	if (task.terminationStatus != 0 && error) {
		NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
		userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Could not create default user.",nil);
		userInfo[NSLocalizedRecoverySuggestionErrorKey] = taskError;
		userInfo[NSLocalizedRecoveryOptionsErrorKey] = @[@"OK", @"Open Server Log"];
		userInfo[NSRecoveryAttempterErrorKey] = [[RecoveryAttempter alloc] init];
		userInfo[@"ServerLogRecoveryOptionIndex"] = @1;
		userInfo[@"ServerLogPath"] = self.logfilePath;
		*error = [NSError errorWithDomain:@"com.postgresapp.Postgres.createuser" code:task.terminationStatus userInfo:userInfo];
	}
	
	return task.terminationStatus == 0;
}

-(BOOL)createUserDatabaseWithError:(NSError **)error {
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = [self.binPath stringByAppendingPathComponent:@"createdb"];
	task.arguments = @[
					   @"-p",
					   @(self.port).stringValue,
					   NSUserName()
	];
	
	task.standardOutput = [[NSPipe alloc] init];
	task.standardError = [[NSPipe alloc] init];
	[task launch];
	NSString *taskError = [[NSString alloc] initWithData:[[task.standardError fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
	[task waitUntilExit];
	
	if (task.terminationStatus != 0 && error) {
		NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
		userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Could not create user database.",nil);
		userInfo[NSLocalizedRecoverySuggestionErrorKey] = taskError;
		userInfo[NSLocalizedRecoveryOptionsErrorKey] = @[@"OK", @"Open Server Log"];
		userInfo[NSRecoveryAttempterErrorKey] = [[RecoveryAttempter alloc] init];
		userInfo[@"ServerLogRecoveryOptionIndex"] = @1;
		userInfo[@"ServerLogPath"] = self.logfilePath;
		*error = [NSError errorWithDomain:@"com.postgresapp.Postgres.createdb" code:task.terminationStatus userInfo:userInfo];
	}
	
	return task.terminationStatus == 0;
}



#pragma mark - Async property helpers

- (void)setIsRunningOnMainThread:(BOOL)isRunning {
	dispatch_async(dispatch_get_main_queue(), ^{ self.isRunning = isRunning; });
}


- (void)setIsBusyOnMainThread:(BOOL)isBusy {
	dispatch_async(dispatch_get_main_queue(), ^{ self.isBusy = isBusy; });
}



#pragma mark - Custom properties

- (void)setIsRunning:(BOOL)isRunning {
	[self willChangeValueForKey:@"statusMessage"];
	_isRunning = isRunning;
	[self didChangeValueForKey:@"statusMessage"];
}


-(NSString *)logfilePath {
	return [self.varPath stringByAppendingPathComponent:@"postgres-server.log"];
}


- (NSString *)statusMessage {
	if (self.isRunning) {
		return [NSString stringWithFormat:@"PostgreSQL %@ – Running on port %lu", self.version, self.port];
	}
	else {
		return [NSString stringWithFormat:@"PostgreSQL %@ – Stopped", self.version];
	}
}


- (NSString *)statusMessageExtended {
	PostgresDataDirectoryStatus dataDirStatus = [self statusOfDataDirectory:self.varPath error:nil];
	switch (dataDirStatus) {
		case PostgresDataDirectoryIncompatible:
			return @"The selected data directory is not compatible with the selected server version.";
			break;
		case PostgresDataDirectoryCompatible:
			return @"Data directory compatible.";
			break;
		case PostgresDataDirectoryEmpty:
			return @"The data directory will be created the first time you start the server.";
			break;
		default:
			break;
	}
	
	return @"STATUS N/A";
}


- (NSArray *)databases {
	NSMutableArray *dbs = [[NSMutableArray alloc] init];
	
	NSString *connectionString = [NSString stringWithFormat:@"postgresql://:%lu", self.port];
	PGconn *conn = PQconnectdb(connectionString.UTF8String);
	PGresult *result = PQexec(conn, "SELECT datname FROM pg_database WHERE datallowconn ORDER BY LOWER(datname)");
	
	//ConnStatusType status = PQstatus(conn);
	
	for (int i=0; i<PQntuples(result); i++) {
		NSString *value = @(PQgetvalue(result, i, 0));
		[dbs addObject:value];
	}
	
	PQfinish(conn);
	
	return dbs;
}





@end
