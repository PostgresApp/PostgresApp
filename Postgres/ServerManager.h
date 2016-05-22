//
//  ServerManager.h
//  Postgres
//
//  Created by Chris on 23.05.16.
//
//

#import <Foundation/Foundation.h>

@interface ServerManager : NSObject

@property NSMutableArray *servers;

+ (ServerManager *)sharedManager;

- (void)saveServerList;
- (void)loadServerList;

@end
