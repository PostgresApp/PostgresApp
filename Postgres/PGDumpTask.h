//
//  PGDumpTask.h
//  Postgres
//
//  Created by Chris on 07/06/16.
//
//

#import <Foundation/Foundation.h>

typedef void (^PGDumpTaskCompletionHandler)(BOOL success, NSError *error);

@class PostgresServer;

@interface PGDumpTask : NSObject

@property PostgresServer *server;
@property NSString *dbName;
@property NSString *filePath;

- (void)startWithCompletionHandler:(PGDumpTaskCompletionHandler)completionBlock;
- (void)cancel;

@end
