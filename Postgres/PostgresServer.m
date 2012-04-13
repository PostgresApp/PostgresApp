//
//  PostgresServer.m
//  PostgreSQL
//
//  Created by Mattt Thompson on 12/04/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

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
    completionBlock:(void (^)())completionBlock
{    
    [self stop];
    [self willChangeValueForKey:@"isRunning"];
    [self willChangeValueForKey:@"port"];
    _port = port;
    
    NSString *existingPGVersion = [NSString stringWithContentsOfFile:[_varPath stringByAppendingPathComponent:@"PG_VERSION"] encoding:NSUTF8StringEncoding error:nil];
    if (!existingPGVersion) {
        [self executeCommandNamed:@"pg_ctl" arguments:[NSArray arrayWithObjects:@"init", [NSString stringWithFormat:@"-D%@", _varPath], nil] terminationHandler:^(NSUInteger status) {
            NSLog(@"InitDB done: %d", status);
            [self executeCommandNamed:@"createdb" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"-p%d", port], NSUserName(), nil] terminationHandler:^(NSUInteger status) {
                [self executeCommandNamed:@"psql" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"-p%d", port], [NSString stringWithFormat:@"-f%@", [[_binPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"share/contrib/postgis-1.5/postgis"]], nil] terminationHandler:nil];
                [self executeCommandNamed:@"pg_ctl" arguments:[NSArray arrayWithObjects:@"start", [NSString stringWithFormat:@"-D%@", _varPath], [NSString stringWithFormat:@"-o'-p%d'", port], nil] terminationHandler:nil];
            }];
        }];    
    } else {
        [self executeCommandNamed:@"pg_ctl" arguments:[NSArray arrayWithObjects:@"start", [NSString stringWithFormat:@"-D%@", _varPath], [NSString stringWithFormat:@"-o'-p%d'", port], nil] terminationHandler:nil];
    }
    
    [self didChangeValueForKey:@"port"];
    [self didChangeValueForKey:@"isRunning"];
    
    if (completionBlock) {
        completionBlock();
    }
    
    return YES;
}

- (BOOL)stop {
    // TODO: Reasonable way to get existing pid
    NSString *pidPath = [_varPath stringByAppendingPathComponent:@"postmaster.pid"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pidPath]) {
        NSString *pid = [[[NSString stringWithContentsOfFile:pidPath encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] objectAtIndex:0];
        
        NSLog(@"PID: %@", pid);

        [self executeCommandNamed:@"pg_ctl" arguments:[NSArray arrayWithObjects:@"kill", @"QUIT", pid, nil] terminationHandler:nil];
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
