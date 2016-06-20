//
//  MainWindowController.m
//  Postgres
//
//  Created by Chris on 17/05/16.
//
//

#import "MainWindowController.h"
#import "AddServerSheetController.h"
#import "DatabasesViewController.h"
#import "IconView.h"
#import "PostgresServer.h"
#import "ServerManager.h"
#import "PGDumpController.h"
#import "PGRestoreController.h"
#import "Terminal.h"

@interface MainWindowController ()
@property AddServerSheetController *addServerSheetController;
@property DatabasesViewController *databasesViewController;
@property NSTask *logTask;
@property (readonly) PostgresServer *selectedServer;
@end


@implementation MainWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
		self.databasesViewController = [[DatabasesViewController alloc] initWithNibName:@"DatabasesView" bundle:nil];
		[self.databasesViewController view];
		self.databasesViewController.iconView.target = self;
		self.databasesViewController.iconView.doubleAction = @selector(openPsql:);
	}
    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];
	
	[self.serverArrayController addObserver:self forKeyPath:@"arrangedObjects.name" options:NSKeyValueObservingOptionNew context:nil];
	[self.serverArrayController addObserver:self forKeyPath:@"arrangedObjects.port" options:NSKeyValueObservingOptionNew context:nil];
	[self.serverArrayController addObserver:self forKeyPath:@"arrangedObjects.runAtStartup" options:NSKeyValueObservingOptionNew context:nil];
	[self.serverArrayController addObserver:self forKeyPath:@"arrangedObjects.stopAtQuit" options:NSKeyValueObservingOptionNew context:nil];
	[self.serverArrayController addObserver:self forKeyPath:@"arrangedObjects.isRunning" options:NSKeyValueObservingOptionNew context:nil];
	[self.serverArrayController addObserver:self forKeyPath:@"selection.logfilePath" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial context:nil];
	[self.serverArrayController rearrangeObjects];
}


- (void)dealloc {
	[self.serverArrayController removeObserver:self forKeyPath:@"arrangedObjects.name"];
	[self.serverArrayController removeObserver:self forKeyPath:@"arrangedObjects.port"];
	[self.serverArrayController removeObserver:self forKeyPath:@"arrangedObjects.runAtStartup"];
	[self.serverArrayController removeObserver:self forKeyPath:@"arrangedObjects.stopAtQuit"];
	[self.serverArrayController removeObserver:self forKeyPath:@"arrangedObjects.isRunning"];
	[self.serverArrayController removeObserver:self forKeyPath:@"selection.logfilePath"];
}



#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
	if ([keyPath isEqualToString:@"arrangedObjects.isRunning"]) {
		if (self.serverArrayController.selectionIndexes.count > 0) {
			[self updateDatabaseView];
			// post status change to PostgresHelper.app
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:kPostgresAppServerStatusChangedNotification object:nil];
		}
	}
	else if ([keyPath isEqualToString:@"selection.logfilePath"]) {
		if (self.serverArrayController.selectionIndexes.count > 0) {
			[self startMonitoringLogFile:self.selectedServer.logfilePath];
			[self updateDatabaseView];
			
		} else {
			[self startMonitoringLogFile:nil];
		}
	}
	else {
		[[ServerManager sharedManager] saveServers];
	}
}



#pragma mark - IBActions

- (IBAction)addServer:(id)sender {
	self.addServerSheetController = [[AddServerSheetController alloc] initWithWindowNibName:@"AddServerSheet"];
	self.addServerSheetController.name = [NSString stringWithFormat:@"Server %lu", self.servers.count+1];
	
	[self.window beginSheet:self.addServerSheetController.window completionHandler:^(NSModalResponse returnCode) {
		if (returnCode == NSModalResponseOK) {
			[self.servers addObject:self.addServerSheetController.server];
			[self.serverArrayController rearrangeObjects];
			[self.serverArrayController setSelectionIndex:self.servers.count-1];
		}
		self.addServerSheetController = nil;
	}];
}


- (IBAction)removeServer:(id)sender {
	NSAlert *alert = [NSAlert alertWithMessageText:@"Delete server?" defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
	
	[alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
		if (returnCode == NSModalResponseOK) {
			NSUInteger selIdx = self.serverArrayController.selectionIndex;
			
			if ([[self.servers objectAtIndex:selIdx] isRunning]) {
				[[self.servers objectAtIndex:selIdx] stopWithCompletionHandler:^(BOOL success, NSError *error) {
					if (!success) {
						[self presentError:error modalForWindow:self.window delegate:nil didPresentSelector:NULL contextInfo:NULL];
					}
				}];
			}
			
			[self.servers removeObjectAtIndex:selIdx];
			[self.serverArrayController rearrangeObjects];
			if (selIdx == self.servers.count) {
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
	
	PostgresServer *selectedServer = self.selectedServer;
    if (selectedServer) {
        NSString *path = selectedServer.varPath;
		if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
	        [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:path];
		} else {
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"Folder not found. It will be created the first time you start the server."};
			NSError *error = [NSError errorWithDomain:@"com.postgresapp.Postgres.missing-folder" code:0 userInfo:userInfo];
			[self presentError:error modalForWindow:self.window delegate:nil didPresentSelector:NULL contextInfo:NULL];
		}
    }
}


- (IBAction)openLogInConsole:(id)sender {
	PostgresServer *selectedServer = self.selectedServer;
	if (selectedServer) {
		NSString *path = selectedServer.logfilePath;
		if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
			[[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:path];
		}
	}
}


- (IBAction)openPsql:(id)sender {
	if (![self.window makeFirstResponder:nil]) {
		NSBeep();
		return;
	}
	
	PostgresServer *selectedServer = self.selectedServer;
	if (selectedServer) {
		NSString *dbName = self.databasesViewController.selectedDBName;
		if (dbName) {
			TerminalApplication *terminal = [SBApplication applicationWithBundleIdentifier:@"com.apple.Terminal"];
			BOOL wasRunning = terminal.isRunning;
			[terminal activate];
			TerminalWindow *window = wasRunning ? nil : terminal.windows.firstObject;
			NSString *psqlScript = [NSString stringWithFormat:@"'%@'/psql -p%u -d %@", [selectedServer.binPath stringByReplacingOccurrencesOfString:@"'" withString:@"'\\''"], (unsigned)selectedServer.port, dbName];
			[terminal doScript:psqlScript in:window.tabs.firstObject];
		}
    }
}


- (IBAction)exportDB:(id)sender {
	NSString *dbName = self.databasesViewController.selectedDBName;
	if (!dbName) {
		return;
	}
	
	PGDumpController *dumpController = [[PGDumpController alloc] initWithServer:self.selectedServer dbName:dbName];
	[dumpController startModalForWindow:self.window];
}


- (IBAction)restoreDB:(id)sender {
	PGRestoreController *restoreController = [[PGRestoreController alloc] initWithServer:self.selectedServer];
	[restoreController startModalForWindow:self.window];
}


- (IBAction)startServer:(id)sender {
	if (![self.window makeFirstResponder:nil]) {
		NSBeep();
		return;
	}
	
	PostgresServer *selectedServer = self.selectedServer;
	if (!selectedServer) {
		return;
	}
	
    PostgresServerControlCompletionHandler completionHandler = ^(BOOL success, NSError *error) {
		if (!success) {
			[self presentError:error modalForWindow:self.window delegate:nil didPresentSelector:NULL contextInfo:NULL];
		}
    };
	
    PostgresServerStatus serverStatus = [selectedServer serverStatus];
	
    if (serverStatus == PostgresServerWrongDataDirectory) {
		NSDictionary *userInfo = @{
								   NSLocalizedDescriptionKey:[NSString stringWithFormat:@"There is already a PostgreSQL server running on port %lu", selectedServer.port],
								   NSLocalizedRecoverySuggestionErrorKey:@"Please stop this server before.\n\nIf you want to use multiple servers, configure them to use different ports."
								   };
		NSError *error = [NSError errorWithDomain:@"com.postgresapp.Postgres.server-status" code:serverStatus userInfo:userInfo];
        completionHandler(NO, error);
    }
	else if (serverStatus == PostgresServerStatusNoBinDir) {
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"The binaries for this PostgreSQL server were not found"};
		NSError *error = [NSError errorWithDomain:@"com.postgresapp.Postgres.server-status" code:serverStatus userInfo:userInfo];
		completionHandler(NO, error);
	}
    else if (serverStatus == PostgresServerRunning) {
        completionHandler(YES, nil);
    }
    else {
        [selectedServer startWithCompletionHandler:completionHandler];
    }
	
}


- (IBAction)stopServer:(id)sender {
	if (![self.window makeFirstResponder:nil]) {
		NSBeep();
		return;
	}
	
	PostgresServer *selectedServer = self.selectedServer;
	if (selectedServer) {
        [selectedServer stopWithCompletionHandler:^(BOOL success, NSError *error) {
			if (!success) {
				[self presentError:error modalForWindow:self.window delegate:nil didPresentSelector:NULL contextInfo:NULL];
			}
		}];
    }
}


- (IBAction)showSettings:(id)sender {
	[self.settingsPopover showRelativeToRect:self.iconViewContainer.bounds ofView:self.iconViewContainer preferredEdge:NSRectEdgeMinY];
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
	NSInteger linesToDel = lines.count - kPostgresAppMaxLogLines - 1; // -1: last line is always empty
	for (NSInteger i=0; i<linesToDel; i++) {
		NSRange newlineRange = [self.logTextView.string rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
		NSUInteger max = NSMaxRange(newlineRange);
		if (max != NSNotFound) {
			[self.logTextView.textStorage.mutableString deleteCharactersInRange:NSMakeRange(0, max)];
		}
	}
}


- (void)updateDatabaseView {
	if (self.selectedServer.isRunning) {
		if (!self.databasesViewController.view.superview) {
			[self.iconViewContainer addSubview:self.databasesViewController.view];
			[self.iconViewContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.iconViewContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.databasesViewController.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
			[self.iconViewContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.iconViewContainer attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.databasesViewController.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
			[self.iconViewContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.iconViewContainer attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.databasesViewController.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
			[self.iconViewContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.iconViewContainer attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.databasesViewController.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
		}
		self.databasesViewController.server = self.selectedServer;
	}
	else {
		while (self.iconViewContainer.subviews.count) {
			[self.iconViewContainer.subviews.lastObject removeFromSuperview];
		}
	}
}



#pragma mark - Custom properties

- (NSMutableArray *)servers {
	return [ServerManager sharedManager].servers;
}

- (void)setServers:(NSMutableArray *)servers {
	[ServerManager sharedManager].servers = servers;
}

- (PostgresServer *)selectedServer {
	return self.servers[self.serverArrayController.selectionIndex];
}



#pragma mark - Custom error sheet

-(void)presentError:(NSError *)error modalForWindow:(NSWindow *)window delegate:(id)delegate didPresentSelector:(SEL)didPresentSelector contextInfo:(void *)contextInfo {
	NSAlert *alert = [NSAlert alertWithError:error];
	
	if (error.userInfo[@"RawCommandOutput"]) {
		NSArray *tlo;
		[[NSBundle mainBundle] loadNibNamed:@"AlertAccessoryView" owner:nil topLevelObjects:&tlo];
		for (id obj in tlo) {
			if ([obj isKindOfClass:[NSScrollView class]]) {
				((NSTextView*)((NSScrollView*)obj).contentView.documentView).textStorage.mutableString.string = error.userInfo[@"RawCommandOutput"];
				alert.accessoryView = obj;
			}
		}
	}
	
	[alert beginSheetModalForWindow:window modalDelegate:delegate didEndSelector:didPresentSelector contextInfo:contextInfo];
}

@end
