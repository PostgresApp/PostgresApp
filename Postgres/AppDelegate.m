//
//  AppDelegate.m
//  PostgreSQL
//
//  Created by Mattt Thompson on 12/04/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "PostgresServer.h"

static NSUInteger kPostgresAppDefaultPort = 5432;

@implementation AppDelegate {
    __strong NSStatusItem *_statusBarItem;
}
@synthesize statusBarMenu;
@synthesize postgresStatusMenuItem;

- (void)awakeFromNib {
    _statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    _statusBarItem.highlightMode = YES;
    _statusBarItem.menu = self.statusBarMenu;
    _statusBarItem.image = [NSImage imageNamed:@"pg-elephant-status-item"];
    
    self.postgresStatusMenuItem.title = NSLocalizedString(@"Postgres: Starting Up...", nil);
    [self.postgresStatusMenuItem setEnabled:NO];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    
    [[PostgresServer sharedServer] startOnPort:kPostgresAppDefaultPort completionBlock:^{
        
        self.postgresStatusMenuItem.title = NSLocalizedString(@"Postgres: Running on Port 5432", nil);
        [self.postgresStatusMenuItem setEnabled:YES];
    }]; 
    
    [NSApp activateIgnoringOtherApps:YES];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    NSLog(@"shouldTerminate");
    
    // TODO: Use termination handlers instead of delay 
    [[PostgresServer sharedServer] stop];
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [sender replyToApplicationShouldTerminate:YES];
    });
    
    return NSTerminateLater;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    NSLog(@"applicationWillTerminate");
}

#pragma mark - IBAction

- (IBAction)selectPostgresStatus:(id)sender {
    
}

- (IBAction)selectAbout:(id)sender {
    [NSApp orderFrontStandardAboutPanel:nil];
}

- (IBAction)selectDocumentation:(id)sender {
    
}

- (IBAction)selectAutomaticallyStart:(id)sender {
    
}

@end
