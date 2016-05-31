//
//  MainWindowController.m
//  Postgres
//
//  Created by Chris on 17/05/16.
//
//


#import "MainWindowController.h"
#import "AddServerSheetController.h"
#import "PostgresServer.h"
#import "ServerManager.h"
#import "Terminal.h"


@interface MainWindowController ()
@property ServerManager *serverManager;
@property AddServerSheetController *addServerSheetController;
@property NSTask *logTask;
@end




@implementation MainWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
		self.serverManager = [ServerManager sharedManager];
    }
    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];
	
	[self.serverArrayController addObserver:self forKeyPath:@"arrangedObjects.name" options:0 context:nil];
	[self.serverArrayController addObserver:self forKeyPath:@"arrangedObjects.port" options:0 context:nil];
	[self.serverArrayController addObserver:self forKeyPath:@"arrangedObjects.runAtStartup" options:0 context:nil];
	[self.serverArrayController addObserver:self forKeyPath:@"arrangedObjects.stopAtQuit" options:0 context:nil];
	[self.serverArrayController addObserver:self forKeyPath:@"selection.logfilePath" options:0 context:nil];
	[self.serverArrayController rearrangeObjects];
}


- (void)dealloc {
	[self.serverArrayController removeObserver:self forKeyPath:@"arrangedObjects.name"];
	[self.serverArrayController removeObserver:self forKeyPath:@"arrangedObjects.port"];
	[self.serverArrayController removeObserver:self forKeyPath:@"arrangedObjects.runAtStartup"];
	[self.serverArrayController removeObserver:self forKeyPath:@"arrangedObjects.stopAtQuit"];
	[self.serverArrayController removeObserver:self forKeyPath:@"selection.logfilePath"];
}



#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	if ([keyPath isEqualToString:@"selection.logfilePath"]) {
		
		if (self.serverArrayController.selectionIndexes.count > 0) {
			NSString *logfilePath = [[self.serverArray objectAtIndex:self.serverArrayController.selectionIndex] logfilePath];
			[self startMonitoringLogFile:logfilePath];
		} else {
			[self startMonitoringLogFile:nil];
		}
	}
	else {
		[self.serverManager saveServers];
	}
}



#pragma mark IBActions
- (IBAction)addServer:(id)sender {
	self.addServerSheetController = [[AddServerSheetController alloc] initWithWindowNibName:@"AddServerSheet"];
	self.addServerSheetController.name = [NSString stringWithFormat:@"Server %lu", self.serverArray.count+1];
	
	[self.window beginSheet:self.addServerSheetController.window completionHandler:^(NSModalResponse returnCode) {
		if (returnCode == NSModalResponseOK) {
			[self.serverArray addObject:self.addServerSheetController.server];
			[self.serverArrayController rearrangeObjects];
			[self.serverArrayController setSelectionIndex:self.serverArray.count-1];
		}
		self.addServerSheetController = nil;
	}];
}


- (IBAction)removeServer:(id)sender {
	NSAlert *alert = [NSAlert alertWithMessageText:@"Delete server?" defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
	
	[alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
		if (returnCode == NSModalResponseOK) {
			NSUInteger selIdx = self.serverArrayController.selectionIndex;
			
			if ([[self.serverArray objectAtIndex:selIdx] isRunning]) {
				[[self.serverArray objectAtIndex:selIdx] stopWithCompletionHandler:^(BOOL success, NSError *error) {
					if (! success) {
						NSAlert *errAlert = [NSAlert alertWithMessageText:@"Could not stop server"
															defaultButton:@"OK"
														  alternateButton:nil
															  otherButton:nil
												informativeTextWithFormat:@"Please kill the process manually."
											 ];
						[errAlert beginSheetModalForWindow:self.window completionHandler:nil];
					}
				}];
			}
			
			[self.serverArray removeObjectAtIndex:selIdx];
			[self.serverArrayController rearrangeObjects];
			if (selIdx == self.serverArray.count) {
				[self.serverArrayController setSelectionIndex:selIdx-1];
			} else {
				[self.serverArrayController setSelectionIndex:selIdx];
			}
		}
	}];
}


- (IBAction)openPathFolder:(id)sender {
	if (![self.window makeFirstResponder:nil]) {
		NSBeep();
		return;
	}
	
    PostgresServer *selSrv = [self.serverArray objectAtIndex:[self.serverArrayController selectionIndex]];
    if (selSrv) {
        NSString *path = selSrv.varPath;
		if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
	        [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:path];
		} else {
			NSAlert *alert = [NSAlert alertWithMessageText:@"Folder not found"
											 defaultButton:@"OK"
										   alternateButton:nil
											   otherButton:nil
								 informativeTextWithFormat:@"It will be created the first time you start the server."
							  ];
			[alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse response) {}];
		}
    }
}


- (IBAction)openPsql:(id)sender {
	if (![self.window makeFirstResponder:nil]) {
		NSBeep();
		return;
	}
	
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
	if (![self.window makeFirstResponder:nil]) {
		NSBeep();
		return;
	}
	
	PostgresServer *selServer = [[self.serverArrayController selectedObjects] lastObject];
	if (! selServer) {
		return;
	}
	
    PostgresServerControlCompletionHandler completionHandler = ^(BOOL success, NSError *error) {
		if (! success) {
			NSAlert *alert = [NSAlert alertWithError:error];
			[alert beginSheetModalForWindow:self.window completionHandler:nil];
		}
    };
	
    PostgresServerStatus serverStatus = [selServer serverStatus];
	
    if (serverStatus == PostgresServerWrongDataDirectory) {
		NSDictionary *userInfo = @{
								   NSLocalizedDescriptionKey:[NSString stringWithFormat:@"There is already a PostgreSQL server running on port %lu", selServer.port],
								   NSLocalizedRecoverySuggestionErrorKey:@"Please stop this server before.\n\nIf you want to use multiple servers, configure them to use different ports."
								   };
		NSError *error = [NSError errorWithDomain:@"com.postgresapp.Postgres.server-status" code:serverStatus userInfo:userInfo];
        completionHandler(NO, error);
    }
	else if (serverStatus == PostgresServerStatusNoBinDir) {
		NSDictionary *userInfo = @{
								   NSLocalizedDescriptionKey:@"The binaries for this PostgreSQL server were not found"
								   };
		NSError *error = [NSError errorWithDomain:@"com.postgresapp.Postgres.server-status" code:serverStatus userInfo:userInfo];
		completionHandler(NO, error);
	}
    else if (serverStatus == PostgresServerRunning) {
        completionHandler(YES, nil);
    }
    else {
        [selServer startWithCompletionHandler:completionHandler];
    }
	
}



- (IBAction)stopServer:(id)sender {
	if (![self.window makeFirstResponder:nil]) {
		NSBeep();
		return;
	}
	
    PostgresServer *selServer = [[self.serverArrayController selectedObjects] lastObject];
    if (! selServer) {
        return;
    }
    
    [selServer stopWithCompletionHandler:^(BOOL success, NSError *error) {
        //NSLog(@"Server on port %lu stopped", selServer.port);
    }];
	
    // Set a timeout interval for postgres shutdown
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kPostgresAppTerminationTimeoutInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){});
}



#pragma mark - Monitor log file
- (void)startMonitoringLogFile:(NSString *)path {
	[NSThread detachNewThreadSelector:@selector(monitorLogFile:) toTarget:self withObject:path];
}


- (void)monitorLogFile:(NSString *)path {
	dispatch_sync(dispatch_get_main_queue(), ^{
		if ([self.logTask isRunning]) {
			[self.logTask terminate];
			self.logTask = nil;
		}
		[self.logTextView.textStorage setAttributedString:[[NSAttributedString alloc] init]];
	});
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return;
	
	NSTask *logTask;
	NSPipe *logPipe;
	
	logTask = [[NSTask alloc] init];
	logPipe = [NSPipe pipe];
	
	logTask.launchPath = @"/usr/bin/tail";
	logTask.arguments = @[@"-n", @(kPostgresAppMaxLogLines).stringValue, @"-f", path];
	logTask.standardOutput = logPipe;
	logTask.standardError = logPipe;
	[logTask launch];
	
	dispatch_sync(dispatch_get_main_queue(), ^{
		self.logTask = logTask;
	});
	
	NSFileHandle *fileHandle = [logPipe fileHandleForReading];
	NSData *data;
	do {
		data = [fileHandle availableData];
		NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		if (str) {
			__block BOOL stop = NO;
			dispatch_sync(dispatch_get_main_queue(), ^{
				if (logTask != self.logTask) {
					stop = YES;
					return;
				};
				[self appendLogEntry:str];
			});
			if (stop) break;
		}
	} while (data.length > 0);
	
	[logTask terminate];
}


- (void)appendLogEntry:(NSString *)str {
	[self.logTextView.textStorage.mutableString appendString:str];
	[self.logTextView scrollRangeToVisible:NSMakeRange(self.logTextView.string.length, 0)];
	
	NSArray *lines = [self.logTextView.string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSUInteger linesToDel = lines.count - kPostgresAppMaxLogLines - 1; // -1: last line is always empty
	for (NSUInteger i=0; i<linesToDel; i++) {
		NSRange newlineRange = [self.logTextView.string rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
		NSUInteger max = NSMaxRange(newlineRange);
		if (max != NSNotFound) {
			[self.logTextView.textStorage.mutableString deleteCharactersInRange:NSMakeRange(0, max)];
		}
	}
}



#pragma mark - Custom properties

- (NSMutableArray *)serverArray {
	return self.serverManager.servers;
}

- (void)setServerArray:(NSMutableArray *)srvArr {
	self.serverManager.servers = srvArr;
}

@end
