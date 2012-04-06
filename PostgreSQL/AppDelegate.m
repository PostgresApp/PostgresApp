//
//  AppDelegate.m
//  PostgreSQL
//
//  Created by Mattt Thompson on 12/04/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "PostgresServer.h"

static NSUInteger kPostgresAppDefaultPort = 6543;

@implementation AppDelegate
@synthesize window = _window;
@synthesize portLabel = _statusLabel;
@synthesize commandTextField = _commandTextField;

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSLog(@"applicationDidFinishLaunching");

    [[PostgresServer sharedServer] startOnPort:kPostgresAppDefaultPort completionBlock:^{
        self.portLabel.stringValue = [[NSNumber numberWithInteger:kPostgresAppDefaultPort] stringValue];
        self.commandTextField.stringValue = [NSString stringWithFormat:@"psql -p %d", kPostgresAppDefaultPort];
    }];    
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

@end
