//
//  MainWindowController.m
//  Postgres
//
//  Created by Chris on 17/05/16.
//
//

#import "MainWindowController.h"
#import "PostgresServer.h"
#import "Terminal.h"


@interface MainWindowController ()

@end




@implementation MainWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        _serverArray = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];    
}




#pragma mark IBActions
- (IBAction)openPathFolder:(id)sender {
    PostgresServer *selSrv = [self.serverArray objectAtIndex:[self.serverArrayController selectionIndex]];
    if (selSrv) {
        NSString *path = selSrv.varPath;
		BOOL isDir = YES;
		if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
	        [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:path];
		} else {
			NSRunAlertPanel(@"Folder not found", @"It will be created the first time you start the server.", @"OK", nil, nil);
		}
    }
}


- (IBAction)openPsql:(id)sender {
	PostgresServer *selSrv = [self.serverArray objectAtIndex:[self.serverArrayController selectionIndex]];
	if (selSrv) {
        TerminalApplication *terminal = [SBApplication applicationWithBundleIdentifier:@"com.apple.Terminal"];
        BOOL wasRunning = terminal.isRunning;
        [terminal activate];
        TerminalWindow *window = wasRunning ? nil : terminal.windows.firstObject;
        NSString *psqlScript = [NSString stringWithFormat:@"'%@'/psql -p%u", [selSrv.binPath stringByReplacingOccurrencesOfString:@"'" withString:@"'\\''"], (unsigned)selSrv.port];
        [terminal doScript:psqlScript in:window.tabs.firstObject];
    }
}



- (IBAction)startServer:(id)sender {
	NSUInteger srvIdx = [self.serverArrayController selectionIndex];
    PostgresServer *selSrv = [self.serverArray objectAtIndex:srvIdx];
    if (! selSrv) {
        NSLog(@"no server selected");
        return;
    }
	
    PostgresServerControlCompletionHandler completionHandler = ^(BOOL success, NSError *error){
        if (success) {
            NSLog(@"Running on Port %lu", selSrv.port);
			[self updateLogString:[NSString stringWithFormat: @"Running on port %lu", selSrv.port] forServer:srvIdx];
        } else {
            NSLog(@"Startup failed");
			[self updateLogString:@"Startup failed" forServer:srvIdx];
        }
    };
	
    PostgresServerStatus serverStatus = [selSrv serverStatus];
    if (serverStatus == PostgresServerWrongDataDirectory) {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:@"There is already a PostgreSQL server running on port %u", (unsigned)selSrv.port],
                                   NSLocalizedRecoverySuggestionErrorKey: @"Please stop this server before starting Postgres.app.\n\nIf you want to use multiple servers, configure them to use different ports."
                                   };
        NSError *error = [NSError errorWithDomain:@"com.postgresapp.Postgres.server-status" code:serverStatus userInfo:userInfo];
        
        NSLog(@"%@", error);
        
        completionHandler(NO, error);
    }
    else if (serverStatus == PostgresServerRunning) {
        // apparently the server is already running... Either the user started it manually, or Postgres.app was force quit
        completionHandler(YES, nil);
    }
    // else if ([self.server stat]) {}
    else {
        // server is not running; try to start it
        [selSrv startWithCompletionHandler:completionHandler];
    }
    
    
}



- (IBAction)stopServer:(id)sender {
    PostgresServer *selServer = [[self.serverArrayController selectedObjects] lastObject];
    
    if (! selServer) {
        return;
    }
    
    [selServer stopWithCompletionHandler:^(BOOL success, NSError *error) {
        NSLog(@"Server on port %lu stopped", selServer.port);
    }];
	
    // Set a timeout interval for postgres shutdown
    static NSTimeInterval const kTerminationTimeoutInterval = 3.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kTerminationTimeoutInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){});
}


- (IBAction)toggleRunAtStartup:(id)sender {
	NSRunAlertPanel(@"", @"Changes will take effect the next time you start Postgres", @"OK", nil, nil);
}



- (void)stopAllServers {
	NSLog(@"Stopping servers...");
	
	for (PostgresServer *srv in self.serverArray) {
		[srv stopWithCompletionHandler:^(BOOL success, NSError *error) {
			NSLog(@"Server on port %lu stopped", srv.port);
		}];
	}
}


- (void)saveServerList {
	if ([self.serverArray count] > 0) {
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.serverArray];
		[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"servers"];
	}
}


- (void)loadServerList {
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"servers"];
	NSMutableArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	if ([arr count] > 0) {
		[self.serverArray addObjectsFromArray:arr];
		[self.serverArrayController rearrangeObjects];
	}
}



#pragma mark - logging
- (void)updateLogString:(NSString *)logString forServer:(NSUInteger)srvIdx {
	[[self.serverArray objectAtIndex:srvIdx] appendLogString:logString];
}



#pragma mark - custom properties
- (NSMutableArray *)serverArray {
	return _serverArray;
}

- (void)setServerArray:(NSMutableArray *)srvArr {
	_serverArray = [srvArr mutableCopy];
	[self saveServerList];
}

@end
