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
    PostgresServer *selServer = [[self.serverArrayController selectedObjects] lastObject];
    if (selServer) {
        NSString *path = selServer.varPath;
        [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:path];
    }
    
}


- (IBAction)openPsql:(id)sender {
    PostgresServer *selServer = [[self.serverArrayController selectedObjects] lastObject];
    if (selServer) {
        TerminalApplication *terminal = [SBApplication applicationWithBundleIdentifier:@"com.apple.Terminal"];
        BOOL wasRunning = terminal.isRunning;
        [terminal activate];
        TerminalWindow *window = wasRunning ? nil : terminal.windows.firstObject;
        NSString *psqlScript = [NSString stringWithFormat:@"'%@'/psql -p%u", [selServer.binPath stringByReplacingOccurrencesOfString:@"'" withString:@"'\\''"], (unsigned)selServer.port];
        [terminal doScript:psqlScript in:window.tabs.firstObject];
    }
}



- (IBAction)startServer:(id)sender {
    // get selected server in tableview
    PostgresServer *selServer = [[self.serverArrayController selectedObjects] lastObject];
    if (! selServer) {
        NSLog(@"no server selected");
        return;
    }
	
    
    PostgresServerControlCompletionHandler completionHandler = ^(BOOL success, NSError *error){
        if (success) {
            NSLog(@"Running on Port %lu", selServer.port);
        } else {
            NSLog(@"Startup failed");
        }
    };
    
    
    
    PostgresServerStatus serverStatus = [selServer serverStatus];
    if (serverStatus == PostgresServerWrongDataDirectory) {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:@"There is already a PostgreSQL server running on port %u", (unsigned)selServer.port],
                                   NSLocalizedRecoverySuggestionErrorKey: @"Please stop this server before starting Postgres.app.\n\nIf you want to use multiple servers, configure them to use different ports."
                                   };
        NSError *error = [NSError errorWithDomain:@"com.postgresapp.Postgres.server-status" code:serverStatus userInfo:userInfo];
        
        NSLog(@"%@", error);
        
        completionHandler(NO, error);
    }
    else if (serverStatus == PostgresServerRunning) {
        /* apparently the server is already running... Either the user started it manually, or Postgres.app was force quit */
        completionHandler(YES, nil);
    }
    /*	else if ([self.server stat]) {
     
     }*/
    else {
        /* server is not running; try to start it */
        [selServer startWithCompletionHandler:completionHandler];
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



- (void)stopAllServers {
	NSLog(@"Stopping servers...");
	
	for (PostgresServer *srv in self.serverArray) {
		[srv stopWithCompletionHandler:^(BOOL success, NSError *error) {
			NSLog(@"Server on port %lu stopped", srv.port);
		}];
	}
}


- (void)saveServerList {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.serverArray];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"servers"];
}


- (void)loadServerList {
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"servers"];
	NSMutableArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	self.serverArray = arr;
	[self.serverArrayController rearrangeObjects];
}



- (NSMutableArray *)serverArray {
	return _serverArray;
}

- (void)setServerArray:(NSMutableArray *)srvArr {
	_serverArray = [srvArr copy];
	[self saveServerList];
}

@end
