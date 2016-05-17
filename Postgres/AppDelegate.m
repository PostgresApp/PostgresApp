// AppDelegate.m
//
// Created by Mattt Thompson (http://mattt.me/)
// Copyright (c) 2012 Heroku (http://heroku.com/)
// 
// Portions Copyright (c) 1996-2012, The PostgreSQL Global Development Group
// Portions Copyright (c) 1994, The Regents of the University of California
//
// Permission to use, copy, modify, and distribute this software and its
// documentation for any purpose, without fee, and without a written agreement
// is hereby granted, provided that the above copyright notice and this
// paragraph and the following two paragraphs appear in all copies.
//
// IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
// DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
// LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
// EVEN IF THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
//
// THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
// FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN
// "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATIONS TO
// PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

#import "AppDelegate.h"
#import "PostgresServer.h"
#import "PostgresStatusMenuItemViewController.h"
#import "WelcomeWindowController.h"
#import "PGApplicationMover.h"
#import "PGShellProfileUpdater.h"
#import "PreferenceWindowController.h"
#import "Terminal.h"

#ifdef SPARKLE
#import <Sparkle/Sparkle.h>
#endif


NSString *const kAppleInterfaceStyle = @"AppleInterfaceStyle";
NSString *const kAppleInterfaceStyleDark = @"Dark";
NSString *const kAppleInterfaceThemeChangedNotification = @"AppleInterfaceThemeChangedNotification";


@interface AppDelegate()
@property (assign, readonly) BOOL isDarkMode;
@property (strong, nonatomic) NSImage *templateOffImage;
@property (strong, nonatomic) NSImage *templateOnImage;
@end


@implementation AppDelegate {
    NSStatusItem *_statusBarItem;
    WelcomeWindowController *_welcomeWindowController;
    id _interfaceThemeObserver;
}

@synthesize postgresStatusMenuItemViewController = _postgresStatusMenuItemViewController;
@synthesize statusBarMenu = _statusBarMenu;
@synthesize postgresStatusMenuItem = _postgresStatusMenuItem;



#pragma mark - NSApplicationDelegate

-(void)applicationWillFinishLaunching:(NSNotification *)notification {
	
	/* Make sure that the app is inside the application directory */
#if !DEBUG
	[[PGApplicationMover sharedApplicationMover] validateApplicationPath];
#endif
	
	/* make sure that there is no other version of Postgres.app running */
	[self validateNoOtherVersionsAreRunning];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{
															  kPostgresShowWelcomeWindowPreferenceKey: @(YES)
															  }];
}


-(void)validateNoOtherVersionsAreRunning {
	NSMutableArray *runningCopies = [NSMutableArray array];
	[runningCopies addObjectsFromArray:[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.heroku.postgres"]];
	[runningCopies addObjectsFromArray:[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.heroku.Postgres"]];
	[runningCopies addObjectsFromArray:[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.heroku.Postgres93"]];
	[runningCopies addObjectsFromArray:[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.postgresapp.Postgres"]];
	[runningCopies addObjectsFromArray:[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.postgresapp.Postgres93"]];
	for (NSRunningApplication *runningCopy in runningCopies) {
		if (![runningCopy isEqual:[NSRunningApplication currentApplication]]) {
			NSAlert *alert = [NSAlert alertWithMessageText: @"Another copy of Postgres.app is already running."
											 defaultButton: @"OK"
										   alternateButton: nil
											   otherButton: nil
								 informativeTextWithFormat: @"Please quit %@ before starting this copy.", runningCopy.localizedName];
			[alert runModal];
			exit(1);
		}
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	
#ifdef SPARKLE
    [self.checkForUpdatesMenuItem setEnabled:YES];
    [self.checkForUpdatesMenuItem setHidden:NO];
#endif
    
    __weak AppDelegate *weakSelf = self;
    _interfaceThemeObserver = [[NSDistributedNotificationCenter defaultCenter] addObserverForName:kAppleInterfaceThemeChangedNotification
                                                                                           object:nil
                                                                                            queue:[NSOperationQueue mainQueue]
                                                                                       usingBlock:^(NSNotification *notification) {
                                                                                           BOOL darkMode = weakSelf.isDarkMode;
                                                                                           weakSelf.templateOffImage.template = darkMode;
                                                                                           weakSelf.templateOnImage.template = darkMode;
                                                                                       }];
    
    _statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    _statusBarItem.highlightMode = YES;
    _statusBarItem.menu = self.statusBarMenu;
	_templateOffImage = [NSImage imageNamed:@"status-off"];
	_templateOnImage = [NSImage imageNamed:@"status-on"];

    BOOL darkMode = self.isDarkMode;
    _templateOffImage.template = darkMode;
    _templateOnImage.template = darkMode;
    
    _statusBarItem.image = _templateOffImage;
	_statusBarItem.alternateImage = _templateOnImage;
	
    [NSApp activateIgnoringOtherApps:YES];
    
    [self.postgresStatusMenuItem setEnabled:NO];
    self.postgresStatusMenuItem.view = self.postgresStatusMenuItemViewController.view;
	
	[[PGShellProfileUpdater sharedUpdater] checkProfiles];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kPostgresShowWelcomeWindowPreferenceKey]) {
		[[WelcomeWindowController sharedController] showWindow:self];
	}
	
	self.mainWindowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
	[self.mainWindowController loadServerList];
	[self.mainWindowController showWindow:nil];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	
	// make sure preferences are saved before quitting
	PreferenceWindowController *prefController = [PreferenceWindowController sharedController];
	if (prefController.isWindowLoaded && prefController.window.isVisible && ![prefController windowShouldClose:prefController.window]) {
		return NSTerminateCancel;
	}
	
	[self.mainWindowController stopAllServers];
	[self.mainWindowController saveServerList];
    
    // Set a timeout interval for postgres shutdown
    static NSTimeInterval const kTerminationTimeoutInterval = 3.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kTerminationTimeoutInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [sender replyToApplicationShouldTerminate:YES];
    });
	
    return NSTerminateLater;
}

- (BOOL)isDarkMode {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kAppleInterfaceStyle] isEqual:kAppleInterfaceStyleDark];
}

- (void)dealloc {
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:_interfaceThemeObserver];
}

#pragma mark - IBActions

- (IBAction)selectAbout:(id)sender {
    // Bring application to foreground to have about window display on top of other windows
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:nil];
}

- (IBAction)openDocumentation:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://postgresapp.com/documentation"]];
}

- (IBAction)openPreferences:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
	[[PreferenceWindowController sharedController] showWindow:nil];
}

- (IBAction)openPsql:(id)sender {
	TerminalApplication* terminal = [SBApplication applicationWithBundleIdentifier:@"com.apple.Terminal"];
	BOOL wasRunning = terminal.isRunning;
	[terminal activate];
	TerminalWindow *window = wasRunning ? nil : terminal.windows.firstObject;
	NSString *psqlScript = [NSString stringWithFormat:@"'%@'/psql -p%u", [self.server.binPath stringByReplacingOccurrencesOfString:@"'" withString:@"'\\''"], (unsigned)self.server.port];
	[terminal doScript:psqlScript in:window.tabs.firstObject];
}

- (IBAction)checkForUpdates:(id)sender {
#ifdef SPARKLE
    [[SUUpdater sharedUpdater] setSendsSystemProfile:YES];
    [[SUUpdater sharedUpdater] checkForUpdates:sender];
#endif
}


- (IBAction)openMainWindow:(id)sender {
    [self.mainWindowController showWindow:nil];
}

@end
