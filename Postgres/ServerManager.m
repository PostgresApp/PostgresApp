//
//  ServerManager.m
//  Postgres
//
//  Created by Chris on 23.05.16.
//
//

#import "ServerManager.h"
#import "PostgresServer.h"


@implementation ServerManager

#pragma mark - Singleton class methods

+ (ServerManager *)sharedManager {
	static ServerManager *__sharedManager = nil;
	if (__sharedManager == nil) {
		__sharedManager = [[[self class] hiddenAlloc] init];
	}
	return __sharedManager;
}


+ (id)alloc {
	NSLog(@"%@ is a singleton - use +sharedInstance", self.class.description);
	return nil;
}


+ (id)hiddenAlloc {
	return [super alloc];
}



#pragma mark - Instance methods

- (id)init {
	self = [super init];
	if (self) {
		self.servers = [[NSMutableArray alloc] init];
	}
	return self;
}


- (void)refreshStatus {
	for (PostgresServer *srv in self.servers) {
		[srv serverStatus];
	}
}


- (void)startServers {
	for (PostgresServer *srv in self.servers) {
		if (srv.runAtStartup) {
			[srv startWithCompletionHandler:^(BOOL success, NSError *error) {}];
		}
	}
}


- (void)stopServers {
	for (PostgresServer *srv in self.servers) {
		if (srv.stopAtQuit) {
			[srv stopWithCompletionHandler:^(BOOL success, NSError *error) {}];
		}
	}
}


- (void)saveServers {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.servers];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"servers"];
}


- (void)loadServers {
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"servers"];
	NSMutableArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	if ([arr count] > 0) {
		[self.servers addObjectsFromArray:arr];
	}
}

@end
