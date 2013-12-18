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

#import <ServiceManagement/ServiceManagement.h>
#import "AppDelegate.h"
#import "PostgresServer.h"
#import "PostgresStatusMenuItemViewController.h"
#import "WelcomeWindowController.h"

#import "Terminal.h"

#ifdef SPARKLE
#import <Sparkle/Sparkle.h>
#endif

static BOOL PostgresIsHelperApplicationSetAsLoginItem() {
    BOOL flag = NO;
    NSArray *jobs = (__bridge NSArray *)SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
    for (NSDictionary *job in jobs) {
        if ([[job valueForKey:@"Label"] isEqualToString:@"com.postgresapp.PostgresHelper"]) {
            flag = YES;
        }
    }
    
    CFRelease((__bridge CFMutableArrayRef)jobs);
    
    return flag;
}

@interface AppDelegate () <PostgresServerMigrationDelegate>
@end

@implementation AppDelegate {
    NSStatusItem *_statusBarItem;
    WelcomeWindowController *_welcomeWindowController;    
}
@synthesize postgresStatusMenuItemViewController = _postgresStatusMenuItemViewController;
@synthesize statusBarMenu = _statusBarMenu;
@synthesize postgresStatusMenuItem = _postgresStatusMenuItem;
@synthesize automaticallyOpenDocumentationMenuItem = _automaticallyOpenDocumentationMenuItem;
@synthesize automaticallyStartMenuItem = _automaticallyStartMenuItem;
@synthesize checkForUpdatesMenuItem = _checkForUpdatesMenuItem;

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	
	[self validateBundleLocation];
		
#ifdef SPARKLE
    [self.checkForUpdatesMenuItem setEnabled:YES];
    [self.checkForUpdatesMenuItem setHidden:NO];
#endif
        
    _statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    _statusBarItem.highlightMode = YES;
    _statusBarItem.menu = self.statusBarMenu;
    _statusBarItem.image = [NSImage imageNamed:@"status-off"];
    _statusBarItem.alternateImage = [NSImage imageNamed:@"status-on"];
        
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kPostgresAutomaticallyOpenDocumentationPreferenceKey]];
    [self.automaticallyOpenDocumentationMenuItem setState:[[NSUserDefaults standardUserDefaults] boolForKey:kPostgresAutomaticallyOpenDocumentationPreferenceKey]];
    [self.automaticallyStartMenuItem setState:PostgresIsHelperApplicationSetAsLoginItem() ? NSOnState : NSOffState];
    
    PostgresServer *server = [PostgresServer sharedServer];
    [server setMigrationDelegate:self];
    [server startWithTerminationHandler:^(NSUInteger status) {
        if (status == 0) {
            [self.postgresStatusMenuItemViewController stopAnimatingWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Running on Port %u", nil), server.port] wasSuccessful:YES];
        } else {
            [self.postgresStatusMenuItemViewController stopAnimatingWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Could not start on Port %u", nil), server.port] wasSuccessful:NO];
        }
    }];
    
    [NSApp activateIgnoringOtherApps:YES];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kPostgresFirstLaunchPreferenceKey]) {        
        _welcomeWindowController = [[WelcomeWindowController alloc] initWithWindowNibName:@"WelcomeWindow"];
        [_welcomeWindowController showWindow:self];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPostgresFirstLaunchPreferenceKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:kPostgresAutomaticallyOpenDocumentationPreferenceKey]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kPostgresAppWebsiteURLString]];
    }
    
    [self.postgresStatusMenuItem setEnabled:NO];
    self.postgresStatusMenuItem.view = self.postgresStatusMenuItemViewController.view;
    [self.postgresStatusMenuItemViewController startAnimatingWithTitle:NSLocalizedString(@"Starting Up", nil)];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	
	if (![[PostgresServer sharedServer] isRunning]) {
		return NSTerminateNow;
	}
	
    [[PostgresServer sharedServer] stopWithTerminationHandler:^(NSUInteger status) {
        [sender replyToApplicationShouldTerminate:YES];
    }];
    
    // Set a timeout interval for postgres shutdown
    static NSTimeInterval const kTerminationTimeoutInterval = 3.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kTerminationTimeoutInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [sender replyToApplicationShouldTerminate:YES];
    });
    
    return NSTerminateLater;
}

#pragma mark -

/**
 * This method ensures that the
 */
-(void)validateBundleLocation {
	NSString *appPath = [[NSBundle mainBundle] bundlePath];
	NSString *errorMessage = nil;
	if (![[appPath lastPathComponent] isEqualToString:@"Postgres.app"]) {
		errorMessage = @"App was renamed";
	}
#if !DEBUG
	else if (![appPath isEqualToString:@"/Applications/Postgres.app"]) {
		errorMessage = @"App not inside Applications folder";
	}
#endif
	if (errorMessage) {
		NSAlert *alert = [NSAlert alertWithMessageText:errorMessage
										 defaultButton:@"Quit"
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:@"To avoid linking issues with bundled libraries, this app must be located exactly at the following path:\n/Applications/Postgres.app"];
		[alert runModal];
		[NSApp terminate:self];
		return;
	}
}

#pragma mark - IBAction

- (IBAction)selectAbout:(id)sender {
    // Bring application to foreground to have about window display on top of other windows
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:nil];
}

- (IBAction)selectDocumentation:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kPostgresAppWebsiteURLString]];
}

- (IBAction)selectPsql:(id)sender {
	TerminalApplication* terminal = [SBApplication applicationWithBundleIdentifier:@"com.apple.Terminal"];
	BOOL wasRunning = terminal.isRunning;
	[terminal activate];
	TerminalWindow *window = wasRunning ? nil : terminal.windows.firstObject;
	NSString *psqlScript = [NSString stringWithFormat:@"%@/psql -p%u", [PostgresServer sharedServer].binPath, (unsigned)[PostgresServer sharedServer].port];
	[terminal doScript:psqlScript in:window.tabs.firstObject];
}

- (IBAction)selectAutomaticallyOpenDocumentation:(id)sender {
    [self.automaticallyOpenDocumentationMenuItem setState:![self.automaticallyOpenDocumentationMenuItem state]];

    [[NSUserDefaults standardUserDefaults] setBool:self.automaticallyOpenDocumentationMenuItem.state == NSOnState forKey:kPostgresAutomaticallyOpenDocumentationPreferenceKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)selectAutomaticallyStart:(id)sender {
    [self.automaticallyStartMenuItem setState:![self.automaticallyStartMenuItem state]];
    
    NSURL *helperApplicationURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"Contents/Library/LoginItems/PostgresHelper.app"];
    if (LSRegisterURL((__bridge CFURLRef)helperApplicationURL, true) != noErr) {
        NSLog(@"LSRegisterURL Failed");
    }
    
    if (!SMLoginItemSetEnabled((__bridge CFStringRef)@"com.postgresapp.PostgresHelper", [self.automaticallyStartMenuItem state] == NSOnState)) {
        NSLog(@"SMLoginItemSetEnabled Failed");
    }
}

- (IBAction)checkForUpdates:(id)sender {
#ifdef SPARKLE
    [[SUUpdater sharedUpdater] setSendsSystemProfile:YES];
    [[SUUpdater sharedUpdater] checkForUpdates:sender];
#endif
}

#pragma mark - PostgresServerMigrationDelegate

- (BOOL)postgresServer:(PostgresServer *)server
shouldMigrateFromVersion:(NSString *)fromVersion
             toVersion:(NSString *)toVersion
{
    NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"Upgrade to Postgres Version %@?", nil), toVersion] defaultButton:NSLocalizedString(@"OK", nil) alternateButton:NSLocalizedString(@"Quit", nil) otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Your current database, configured for Postgres %@, will have its data moved to `var-%@`.\n\nA new data directory at `var`, configured for Postgres %@ will be initialized in its place.", nil), fromVersion, fromVersion, toVersion];
    NSInteger result = [alert runModal];
    
    return result == NSAlertDefaultReturn;
}

@end
