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

@interface AppDelegate ()
@property NSStatusItem *statusBarItem;
@property (readonly) BOOL isDarkMode;
@property (nonatomic) NSImage *templateOffImage;
@property (nonatomic) NSImage *templateOnImage;
@property id interfaceThemeObserver;
@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	//[[NSWorkspace sharedWorkspace] launchApplication:@"/Applications/Postgres.app"];
	//[NSApp terminate:self];
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
}


- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self.interfaceThemeObserver];
}



#pragma mark IBActions

- (IBAction)openAbout:(id)sender {
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp orderFrontStandardAboutPanel:nil];
}

- (IBAction)openDocumentation:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://postgresapp.com/documentation"]];
}

- (IBAction)openPostgresApp:(id)sender {
	
}



#pragma mark - Custom properties

- (BOOL)isDarkMode {
	return [[[NSUserDefaults standardUserDefaults] objectForKey:kAppleInterfaceStyle] isEqual:kAppleInterfaceStyleDark];
}

@end
