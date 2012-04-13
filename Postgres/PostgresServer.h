//
//  PostgresServer.h
//  PostgreSQL
//
//  Created by Mattt Thompson on 12/04/05.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostgresServer : NSObject

@property (readonly) BOOL isRunning;
@property (readonly) NSUInteger port;

+ (PostgresServer *)sharedServer;

- (id)initWithExecutablesDirectory:(NSString *)executablesDirectory
                 databaseDirectory:(NSString *)databaseDirectory;

- (BOOL)startOnPort:(NSUInteger)port
    completionBlock:(void (^)())completionBlock;
- (BOOL)stop;

- (void)executeCommandNamed:(NSString *)command 
                  arguments:(NSArray *)arguments
         terminationHandler:(void (^)(NSUInteger status))terminationHandler;

@end
