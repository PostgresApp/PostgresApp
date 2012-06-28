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

@implementation PostgresServer {
    __strong NSString *_binPath;
    __strong NSString *_varPath;
    __strong NSTask *_postgresTask;
    NSUInteger _port;
    
    xpc_connection_t _xpc_connection;
}

+ (PostgresServer *)sharedServer {
    static PostgresServer *_sharedServer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedServer = [[PostgresServer alloc] initWithExecutablesDirectory:[[NSBundle mainBundle] pathForAuxiliaryExecutable:@"bin"] databaseDirectory:[[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"var"]];
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
    
    _xpc_connection = xpc_connection_create("com.heroku.postgres-service", dispatch_get_main_queue());
	xpc_connection_set_event_handler(_xpc_connection, ^(xpc_object_t event) {        
        xpc_dictionary_apply(event, ^bool(const char *key, xpc_object_t value) {
			return true;
		});
	});
	xpc_connection_resume(_xpc_connection);
    
    return self;
}

- (NSUInteger)port {
    return [self isRunning] ? _port : NSNotFound;
}

- (BOOL)isRunning {
    return _port != 0;
}

- (BOOL)startOnPort:(NSUInteger)port 
 terminationHandler:(void (^)(NSUInteger status))completionBlock
{    
    [self stopWithTerminationHandler:nil];
    [self willChangeValueForKey:@"isRunning"];
    [self willChangeValueForKey:@"port"];
    _port = port;
    
    NSString *existingPGVersion = [NSString stringWithContentsOfFile:[_varPath stringByAppendingPathComponent:@"PG_VERSION"] encoding:NSUTF8StringEncoding error:nil];
    if (!existingPGVersion) {
        [self executeCommandNamed:@"initdb" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"-D%@", _varPath], [NSString stringWithFormat:@"-E%@", @"UTF8"], [NSString stringWithFormat:@"--locale=%@_%@", [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode], [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]], nil] terminationHandler:^(NSUInteger status) {
            [self executeCommandNamed:@"pg_ctl" arguments:[NSArray arrayWithObjects:@"start", [NSString stringWithFormat:@"-D%@", _varPath], @"-w", [NSString stringWithFormat:@"-o'-p%d'", port], nil] terminationHandler:^(NSUInteger status) {
                [self executeCommandNamed:@"createdb" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"-p%d", port], NSUserName(), nil] terminationHandler:^(NSUInteger status) {
                    if (completionBlock) {
                        completionBlock(status);
                    }
                }];
            }];
        }];    
    } else {
        [self executeCommandNamed:@"pg_ctl" arguments:[NSArray arrayWithObjects:@"start", [NSString stringWithFormat:@"-D%@", _varPath], [NSString stringWithFormat:@"-o'-p%d'", port], nil] terminationHandler:^(NSUInteger status) {
            // Kill server and try one more time if server can't be started
            if (status != 0) {
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [self stopWithTerminationHandler:^(NSUInteger status) {
                        [self startOnPort:port terminationHandler:completionBlock];
                    }];
                });
            }
            
            if (completionBlock) {
                completionBlock(status);
            }
        }];
    }
    
    [self didChangeValueForKey:@"port"];
    [self didChangeValueForKey:@"isRunning"];
    
    return YES;
}

- (BOOL)stopWithTerminationHandler:(void (^)(NSUInteger status))terminationHandler {
    NSString *pidPath = [_varPath stringByAppendingPathComponent:@"postmaster.pid"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pidPath]) {
        NSString *pid = [[[NSString stringWithContentsOfFile:pidPath encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] objectAtIndex:0];
        NSLog(@"Pid: %@", pid);
        [self executeCommandNamed:@"pg_ctl" arguments:[NSArray arrayWithObjects:@"kill", @"QUIT", pid, nil] terminationHandler:terminationHandler];
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
