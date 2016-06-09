//
//  PGRestoreTask.h
//  Postgres
//
//  Created by Chris on 09/06/16.
//
//

#import <Foundation/Foundation.h>

typedef void (^PGRestoreTaskCompletionHandler)(BOOL success, NSError *error);

@class PostgresServer;

@interface PGRestoreTask : NSObject

@property PostgresServer *server;
@property NSString *dbName;
@property NSString *filePath;

- (void)startWithCompletionHandler:(PGRestoreTaskCompletionHandler)completionBlock;
- (void)cancel;

@end
