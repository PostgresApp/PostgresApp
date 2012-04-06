//
//  PostgresServer.m
//  PostgreSQL
//
//  Created by Mattt Thompson on 12/04/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PostgresServer.h"
#import "NSFileManager+DirectoryLocations.h"

@implementation PostgresServer {
    __strong NSString *_binPath;
    __strong NSString *_varPath;
    __strong NSTask *_postgresTask;
    NSUInteger _port;
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
        [self executeCommandNamed:@"initdb" arguments:[NSArray arrayWithObject:[NSString stringWithFormat:@"-D%@", _varPath]] terminationHandler:^{
            _postgresTask = [self executeCommandNamed:@"postgres" arguments:mutableArguments terminationHandler:nil];
            
            // TODO replace with FSEvent-based approach
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                [self executeCommandNamed:@"createdb" arguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"-p %d", port], NSUserName(), nil] terminationHandler:nil];
            });
        }];
    } else {
        _postgresTask = [self executeCommandNamed:@"postgres" arguments:mutableArguments terminationHandler:nil];
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

- (NSTask *)executeCommandNamed:(NSString *)command 
                    arguments:(NSArray *)arguments
             terminationHandler:(void (^)())terminationHandler
{
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [_binPath stringByAppendingPathComponent:command];
    if (![[NSFileManager defaultManager] fileExistsAtPath:task.launchPath]) {
        [[NSException exceptionWithName:@"" reason:nil userInfo:nil] raise];
    }
    
    task.arguments = arguments;
    task.terminationHandler = terminationHandler;
    [task launch];

    return task;
}

@end
