// AppDelegate.m
//
// Created by Mattt Thompson (http://mattt.me/)
// Copyright (c) 2012 Heroku (http://heroku.com/)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AppDelegate.h"
#import "ServerManager.h"
#import "PostgresServer.h"
#import "MenuItemViewController.h"

@interface AppDelegate ()
@property NSStatusItem *statusBarItem;
@property (readonly) BOOL isDarkMode;
@property (nonatomic) NSImage *templateOffImage;
@property (nonatomic) NSImage *templateOnImage;
@property id interfaceThemeObserver;
@property ServerManager *serverManager;
@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	__weak AppDelegate *weakSelf = self;
	self.interfaceThemeObserver = [[NSDistributedNotificationCenter defaultCenter] addObserverForName:kAppleInterfaceThemeChangedNotification
																							   object:nil
																								queue:[NSOperationQueue mainQueue]
																						   usingBlock:^(NSNotification *notification) {
																							   BOOL darkMode = weakSelf.isDarkMode;
																							   weakSelf.templateOffImage.template = darkMode;
																							   weakSelf.templateOnImage.template = darkMode;
																						   }];
	
	self.templateOffImage = [NSImage imageNamed:@"status-off"];
	self.templateOnImage = [NSImage imageNamed:@"status-on"];
	self.templateOffImage.template = self.isDarkMode;
	self.templateOnImage.template = self.isDarkMode;
	
	self.statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	self.statusBarItem.highlightMode = YES;
	self.statusBarItem.menu = self.statusMenu;
	self.statusBarItem.image = self.templateOffImage;
	self.statusBarItem.alternateImage = self.templateOnImage;
	
	[[ServerManager sharedManager] loadServersForHelperApp];
	[[ServerManager sharedManager] refreshStatus];
	[[ServerManager sharedManager] startServers];
	
	[self generateMenuItems];
	
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(serverStatusChanged:) name:kPostgresAppServerStatusChangedNotification object:nil];
	
}


- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self.interfaceThemeObserver];
}



#pragma mark - IBActions

- (IBAction)openPostgresApp:(id)sender {
	[[NSWorkspace sharedWorkspace] launchApplication:@"/Applications/Postgres.app"];
}

- (IBAction)openPsql:(NSMenuItem *)sender {
	NSString *dbName = sender.title;
	NSLog(@"%@",dbName);
}



#pragma mark - PostgresAppServerStatusChangedNotification

- (void)serverStatusChanged:(id)userInfo {
	NSLog(@"serverStatusChanged:");
	[self generateMenuItems];
}



#pragma mark - NSMenuItem generataion

- (void)generateMenuItems {
	NSArray *servers = [[ServerManager sharedManager] servers];
	NSUInteger idx = 0;
	for (PostgresServer *server in servers) {
		[self.statusBarItem.menu insertItem:[self menuItemWithServer:server] atIndex:idx++];
		
		for (NSString *dbName in server.databases) {
			NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:dbName action:@selector(openPsql:) keyEquivalent:@""];
			[self.statusBarItem.menu insertItem:item atIndex:idx++];
		}
	}
}

- (NSMenuItem *)menuItemWithServer:(PostgresServer *)server {
	MenuItemViewController *viewController = [[MenuItemViewController alloc] initWithNibName:@"MenuItemView" bundle:nil];
	viewController.name = server.name;
	viewController.statusImage = [NSImage imageNamed:(server.isRunning) ? NSImageNameStatusAvailable : NSImageNameStatusUnavailable];
	NSMenuItem *menuItem = [[NSMenuItem alloc] init];
	menuItem.view = viewController.view;
	return menuItem;
}



#pragma mark - Custom properties

- (BOOL)isDarkMode {
	return [[[NSUserDefaults standardUserDefaults] objectForKey:kAppleInterfaceStyle] isEqual:kAppleInterfaceStyleDark];
}

@end
