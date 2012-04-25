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

#import <ServiceManagement/ServiceManagement.h>
#import "AppDelegate.h"
#import "PostgresServer.h"
#import "PostgresStatusMenuItemViewController.h"

static NSString * const kPostgresAppWebsiteURLString = @"http://postgresapp.com/documentation";
static NSUInteger const kPostgresAppDefaultPort = 5432;

static NSString * const kPostgresAutomaticallyOpenDocumentationPreferenceKey = @"com.heroku.postgres.preference.open-documentation-at-start";

static BOOL PostgresIsHelperApplicationSetAsLoginItem() {
    NSArray *jobs = (__bridge NSArray *)SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
    for (NSDictionary *job in jobs) {
        if ([[job valueForKey:@"Label"] isEqualToString:@"com.heroku.PostgresHelper"]) {
            return YES;
        }
    }
    
    return NO;
}


@implementation AppDelegate {
    __strong NSStatusItem *_statusBarItem;
}
@synthesize postgresStatusMenuItemViewController = _postgresStatusMenuItemViewController;
@synthesize statusBarMenu = _statusBarMenu;
@synthesize postgresStatusMenuItem = _postgresStatusMenuItem;
@synthesize automaticallyOpenDocumentationMenuItem = _automaticallyOpenDocumentationMenuItem;
@synthesize automaticallyStartMenuItem = _automaticallyStartMenuItem;

- (void)awakeFromNib {
    _statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    _statusBarItem.highlightMode = YES;
    _statusBarItem.menu = self.statusBarMenu;
    _statusBarItem.image = [NSImage imageNamed:@"pg-elephant-status-item"];
    _statusBarItem.alternateImage = [NSImage imageNamed:@"pg-elephant-status-item-highlight"];
    
    [self.postgresStatusMenuItem setEnabled:NO];    
    self.postgresStatusMenuItem.view = self.postgresStatusMenuItemViewController.view;
    [self.postgresStatusMenuItemViewController startAnimatingWithTitle:NSLocalizedString(@"Postgres: Starting Up", nil)];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kPostgresAutomaticallyOpenDocumentationPreferenceKey]];
    [self.automaticallyOpenDocumentationMenuItem setState:[[NSUserDefaults standardUserDefaults] boolForKey:kPostgresAutomaticallyOpenDocumentationPreferenceKey]];
    [self.automaticallyStartMenuItem setState:PostgresIsHelperApplicationSetAsLoginItem() ? NSOnState : NSOffState];
    
    [[PostgresServer sharedServer] startOnPort:kPostgresAppDefaultPort completionBlock:^{
        [self.postgresStatusMenuItemViewController stopAnimatingWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Postgres: Running on Port %u", nil), kPostgresAppDefaultPort] wasSuccessful:YES];
    }]; 
        
    [NSApp activateIgnoringOtherApps:YES];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kPostgresAutomaticallyOpenDocumentationPreferenceKey]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kPostgresAppWebsiteURLString]];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {    
    // TODO: Use termination handlers instead of delay 
    [[PostgresServer sharedServer] stop];
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [sender replyToApplicationShouldTerminate:YES];
    });
    
    return NSTerminateLater;
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

- (IBAction)selectAutomaticallyOpenDocumentation:(id)sender {
    [self.automaticallyOpenDocumentationMenuItem setState:![self.automaticallyOpenDocumentationMenuItem state]];

    [[NSUserDefaults standardUserDefaults] setBool:self.automaticallyOpenDocumentationMenuItem.state == NSOnState forKey:kPostgresAutomaticallyOpenDocumentationPreferenceKey];
}

- (IBAction)selectAutomaticallyStart:(id)sender {
    [self.automaticallyStartMenuItem setState:![self.automaticallyStartMenuItem state]];
    
    NSURL *helperApplicationURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"Contents/Library/LoginItems/PostgresHelper.app"];
    NSLog(@"Helper Application URL: %@", helperApplicationURL);
    if (LSRegisterURL((__bridge CFURLRef)helperApplicationURL, true) != noErr) {
        NSLog(@"LSRegisterURL Failed");
    }
    
    if (!SMLoginItemSetEnabled((__bridge CFStringRef)@"com.heroku.PostgresHelper", [self.automaticallyStartMenuItem state] == NSOnState)) {
        NSLog(@"SMLoginItemSetEnabled Failed");
    }
}

@end
