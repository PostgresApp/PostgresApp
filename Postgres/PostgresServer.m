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
			NSLog(@"XPC %s: %s", key, xpc_string_get_string_ptr(value));
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
        [self executeCommandNamed:@"pg_ctl" arguments:[NSArray arrayWithObjects:@"init", [NSString stringWithFormat:@"-D%@", _varPath], nil]];    
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self executeCommandNamed:@"pg_ctl" arguments:[NSArray arrayWithObjects:@"start", [NSString stringWithFormat:@"-D%@", _varPath], [NSString stringWithFormat:@"-o'-p%d'", port], nil]];
            
            // TODO replace with FSEvent-based approach
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
                [self executeCommandNamed:@"createdb" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"-p%d", port], NSUserName(), nil]];
            });
        });
    } else {
        [self executeCommandNamed:@"pg_ctl" arguments:[NSArray arrayWithObjects:@"start", [NSString stringWithFormat:@"-D%@", _varPath], [NSString stringWithFormat:@"-o'-p%d'", port], nil]];
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

        [self executeCommandNamed:@"pg_ctl" arguments:[NSArray arrayWithObjects:@"kill", @"QUIT", pid, nil]];
    }
    
    return YES;
}

- (void)executeCommandNamed:(NSString *)command 
                  arguments:(NSArray *)arguments
{
	xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);

    xpc_dictionary_set_string(message, "command", [[_binPath stringByAppendingPathComponent:command] UTF8String]);
    
    xpc_object_t args = xpc_array_create(NULL, 0);
    [arguments enumerateObjectsUsingBlock:^(id argument, NSUInteger idx, BOOL *stop) {
        xpc_array_set_value(args, XPC_ARRAY_APPEND, xpc_string_create([argument UTF8String]));
    }];
    xpc_dictionary_set_value(message, "arguments", args);
    
    xpc_connection_send_message_with_reply(_xpc_connection, message, dispatch_get_main_queue(), ^(xpc_object_t object) {
        NSLog(@"Response: %s" , xpc_string_get_string_ptr(object));
    });
}

@end
