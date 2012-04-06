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
        _sharedServer = [[PostgresServer alloc] initWithExecutablesDirectory:[[NSBundle mainBundle] pathForAuxiliaryExecutable:@"postgres/bin"] databaseDirectory:[[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"var"]];
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
    
    _xpc_connection = xpc_connection_create("com.postgres.initdb_service", dispatch_get_main_queue());
	xpc_connection_set_event_handler(_xpc_connection, ^(xpc_object_t event) {
        NSLog(@"XPC");
        
        xpc_dictionary_apply(event, ^bool(const char *key, xpc_object_t value) {
			NSLog(@"XPC %s: %s", key, xpc_string_get_string_ptr(value));
			return true;
		});
	});
	xpc_connection_resume(_xpc_connection);
    
    NSLog(@"var: %@", _varPath);
    NSLog(@"bin: %@", _binPath);
    return self;
}

- (NSUInteger)port {
    return [self isRunning] ? _port : NSNotFound;
}

- (BOOL)isRunning {
    return [_postgresTask isRunning];
}

- (BOOL)startOnPort:(NSUInteger)port 
    completionBlock:(void (^)())completionBlock
{
    if ([self isRunning]) {
        return NO;
    }
    
    NSMutableArray *mutableArguments = [NSMutableArray array];
    [mutableArguments addObject:[NSString stringWithFormat:@"-D%@", _varPath]];
    [mutableArguments addObject:[NSString stringWithFormat:@"-p%d", port]];
    
    NSString *existingPGVersion = [NSString stringWithContentsOfFile:[_varPath stringByAppendingPathComponent:@"PG_VERSION"] encoding:NSUTF8StringEncoding error:nil];
    
    [self willChangeValueForKey:@"isRunning"];
    [self willChangeValueForKey:@"port"];
    _port = port;

    if (!existingPGVersion) {
        [self executeCommandNamed:@"initdb" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"-D%@", _varPath], [NSString stringWithFormat:@"-d"], nil]];    
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self executeCommandNamed:@"postgres" arguments:mutableArguments];
            
            // TODO replace with FSEvent-based approach
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
                [self executeCommandNamed:@"createdb" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"-p %d", port], NSUserName(), nil]];
            });
        });
    } else {
        [self executeCommandNamed:@"postgres" arguments:mutableArguments];
    }
    
    [self didChangeValueForKey:@"port"];
    [self didChangeValueForKey:@"isRunning"];
    
    if (completionBlock) {
        completionBlock();
    }
    
    return YES;
}

- (BOOL)stop {
    if (![self isRunning]) {
        return NO;
    }
    
    [_postgresTask terminate];
    
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
