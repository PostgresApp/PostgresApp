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

@end

@implementation PostgresServer {
    __strong NSTask *_postgresTask;
    NSUInteger _port;
    
    xpc_connection_t _xpc_connection;
}

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

+(PostgresServer *)sharedServer {
    static PostgresServer *_sharedServer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		NSString *binDirectory = [[NSBundle mainBundle].bundlePath stringByAppendingFormat:@"/Contents/Versions/%s/bin",xstr(PG_MAJOR_VERSION)];
		NSString *databaseDirectory = [[NSUserDefaults standardUserDefaults] stringForKey:kPostgresDataDirectoryPreferenceKey];
		if (!databaseDirectory || [self statusOfDataDirectory:databaseDirectory] == PostgresDataDirectoryIncompatible) {
			databaseDirectory = [self existingDatabaseDirectory];
		}
		if (!databaseDirectory) {
			databaseDirectory = [self standardDatabaseDirectory];
		}
		[[NSUserDefaults standardUserDefaults] setObject:databaseDirectory forKey:kPostgresDataDirectoryPreferenceKey];
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

    _xpc_connection = xpc_connection_create("com.postgresapp.postgres-service", dispatch_get_main_queue());
	xpc_connection_set_event_handler(_xpc_connection, ^(xpc_object_t event) {
        xpc_dictionary_apply(event, ^bool(const char *key, xpc_object_t value) {
			return true;
		});
	});
	xpc_connection_resume(_xpc_connection);
    
    return self;
}

- (BOOL)startWithTerminationHandler:(void (^)(NSUInteger status))completionBlock
{
    [self stopWithTerminationHandler:nil];
    
    PostgresDataDirectoryStatus dataDirStatus = [PostgresServer statusOfDataDirectory:_varPath];
	
    if (dataDirStatus==PostgresDataDirectoryEmpty) {
        [self executeCommandNamed:@"initdb" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"-D%@", _varPath], [NSString stringWithFormat:@"-E%@", @"UTF8"], [NSString stringWithFormat:@"--locale=%@_%@.UTF-8", [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode], [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]], nil] terminationHandler:^(NSUInteger status) {
			if (status!=0) {
				if (completionBlock) {
					completionBlock(status);
				}
			} else {
				[self executeCommandNamed:@"pg_ctl" arguments:[NSArray arrayWithObjects:@"start", [NSString stringWithFormat:@"-D%@", _varPath], @"-w", [NSString stringWithFormat:@"-o'-p%ld'", _port], nil] terminationHandler:^(NSUInteger status) {
					if (status!=0) {
						if (completionBlock) {
							completionBlock(status);
						}
					} else {
						self.isRunning = YES;
						[self executeCommandNamed:@"createdb" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"-p%ld", _port], NSUserName(), nil] terminationHandler:^(NSUInteger status) {
							if (completionBlock) {
								completionBlock(status);
							}
						}];
					}
				}];
			}
        }];
    }
	else if (dataDirStatus==PostgresDataDirectoryCompatible) {
        [self executeCommandNamed:@"pg_ctl" arguments:[NSArray arrayWithObjects:@"start", @"-w", [NSString stringWithFormat:@"-D%@", _varPath], nil] terminationHandler:^(NSUInteger status) {
            self.isRunning = (status == 0);
            if (completionBlock) {
                completionBlock(status);
            }
        }];
    }
	else {
		if (completionBlock) {
			completionBlock(1);
		}
	}
    
    
    return YES;
}

- (BOOL)stopWithTerminationHandler:(void (^)(NSUInteger status))terminationHandler {
    NSString *pidPath = [_varPath stringByAppendingPathComponent:@"postmaster.pid"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pidPath]) {
        NSString *pid = [[[NSString stringWithContentsOfFile:pidPath encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] objectAtIndex:0];        
        [self executeCommandNamed:@"pg_ctl" arguments:[NSArray arrayWithObjects:@"kill", @"INT", pid, nil] terminationHandler:terminationHandler];
        [[NSFileManager defaultManager] removeItemAtPath:pidPath error:nil];
    }
    
    return YES;
}

- (void)executeCommandNamed:(NSString *)command 
                  arguments:(NSArray *)arguments
         terminationHandler:(void (^)(NSUInteger status))terminationHandler
{
	xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);

    xpc_dictionary_set_string(message, "command", [[_binPath stringByAppendingPathComponent:command] UTF8String]);
    
    xpc_object_t args = xpc_array_create(NULL, 0);
    [arguments enumerateObjectsUsingBlock:^(id argument, NSUInteger idx, BOOL *stop) {
        xpc_array_set_value(args, XPC_ARRAY_APPEND, xpc_string_create([argument UTF8String]));
    }];
    xpc_dictionary_set_value(message, "arguments", args);
    
    xpc_connection_send_message_with_reply(_xpc_connection, message, dispatch_get_main_queue(), ^(xpc_object_t object) {
        NSLog(@"%lld %s: Status %lld", xpc_dictionary_get_int64(object, "pid"), xpc_dictionary_get_string(object, "command"), xpc_dictionary_get_int64(object, "status"));
        
        if (terminationHandler) {
            terminationHandler(xpc_dictionary_get_int64(object, "status"));
        }
    });
}

@end
