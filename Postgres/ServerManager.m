//
//  ServerManager.m
//  Postgres
//
//  Created by Chris on 23.05.16.
//
//

#import "ServerManager.h"

@implementation ServerManager

+ (ServerManager *)sharedManager {
	static ServerManager *sharedManager = nil;
	if (sharedManager == nil) {
		sharedManager = [[[self class] hiddenAlloc] init];
	}
	return sharedManager;
}


+ (id)alloc {
	NSLog(@"%@ is a singleton - use +sharedInstance", [self.class description]);
	return nil;
}


+ (id)hiddenAlloc {
	return [super alloc];
}



#pragma mark - instance methods

- (id)init {
	self = [super init];
	if (self) {
		self.servers = [[NSMutableArray alloc] init];
	}
	return self;
}


- (void)saveServerList {
	if ([self.servers count] > 0) {
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.servers];
		[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"servers"];
	}
}


- (void)loadServerList {
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"servers"];
	NSMutableArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	if ([arr count] > 0) {
		[self.servers addObjectsFromArray:arr];
	}
}

@end
