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
	static ServerManager *sharedManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedManager = [[self.class hiddenAlloc] init];
	});
	return sharedManager;
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
	for (PostgresServer *server in self.servers) {
		[server serverStatus];
	}
}


- (void)startServers {
	for (PostgresServer *server in self.servers) {
		if (server.runAtStartup) {
			[server startWithCompletionHandler:^(BOOL success, NSError *error) {
				NSLog(@"%@ started with success=%d error=%@", server.name, success, error);
			}];
		}
	}
}


- (void)stopServers {
	for (PostgresServer *server in self.servers) {
		if (server.stopAtQuit) {
			[server stopWithCompletionHandler:^(BOOL success, NSError *error) {}];
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


- (void)loadServersForHelperApp {
	NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.postgresapp.Postgres"];
	NSData *data = [defaults objectForKey:@"servers"];
	NSMutableArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	if ([arr count] > 0) {
		[self.servers addObjectsFromArray:arr];
	}
}

@end
