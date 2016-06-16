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

- (void)refreshStatus;
- (void)startServers;
- (void)stopServers;
- (void)saveServers;
- (void)loadServers;
- (void)loadServersForHelperApp;

@end
