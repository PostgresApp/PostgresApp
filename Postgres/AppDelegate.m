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
#import "MainWindowController.h"
#import "PostgresServer.h"
#import "ServerManager.h"
#import "PGApplicationMover.h"
#import "PGShellProfileUpdater.h"
#import "Terminal.h"

#ifdef SPARKLE
#import <Sparkle/Sparkle.h>
#endif


@interface AppDelegate()
@property MainWindowController *mainWindowController;
@end


@implementation AppDelegate

#pragma mark - NSApplicationDelegate

-(void)applicationWillFinishLaunching:(NSNotification *)notification {
	// make sure that the app is inside the application directory
	#if !DEBUG
	[[PGApplicationMover sharedApplicationMover] validateApplicationPath];
	#endif
	// make sure that there is no other version of Postgres.app running
	[self validateNoOtherVersionsAreRunning];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	[[ServerManager sharedManager] loadServers];
	[[ServerManager sharedManager] refreshStatus];
	[[ServerManager sharedManager] startServers];
	
	[NSApp activateIgnoringOtherApps:YES];
	[[PGShellProfileUpdater sharedUpdater] checkProfiles];
	
	self.mainWindowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
	[self.mainWindowController showWindow:nil];
}

-(void)applicationDidBecomeActive:(NSNotification *)notification {
	[[ServerManager sharedManager] refreshStatus];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	[[ServerManager sharedManager] stopServers];
	return NSTerminateNow;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}



#pragma mark - Helper methods

-(void)validateNoOtherVersionsAreRunning {
	NSMutableArray *runningCopies = [NSMutableArray array];
	[runningCopies addObjectsFromArray:[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.heroku.postgres"]];
	[runningCopies addObjectsFromArray:[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.heroku.Postgres"]];
	[runningCopies addObjectsFromArray:[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.heroku.Postgres93"]];
	[runningCopies addObjectsFromArray:[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.postgresapp.Postgres"]];
	[runningCopies addObjectsFromArray:[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.postgresapp.Postgres93"]];
	for (NSRunningApplication *runningCopy in runningCopies) {
		if (![runningCopy isEqual:[NSRunningApplication currentApplication]]) {
			NSAlert *alert = [NSAlert alertWithMessageText:@"Another copy of Postgres.app is already running."
											 defaultButton:@"OK"
										   alternateButton:nil
											   otherButton:nil
								 informativeTextWithFormat:@"Please quit %@ before starting this copy.", runningCopy.localizedName];
			[alert runModal];
			exit(1);
		}
	}
}

@end
