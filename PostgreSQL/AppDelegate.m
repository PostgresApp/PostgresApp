//
//  AppDelegate.m
//  PostgreSQL
//
//  Created by Mattt Thompson on 12/04/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "PostgresServer.h"

@interface AppDelegate ()
@end

@implementation AppDelegate
@synthesize window = _window;
@synthesize portLabel = _statusLabel;
@synthesize commandTextField = _commandTextField;

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSLog(@"applicationDidFinishLaunching");

    NSUInteger port = 9900;
    [[PostgresServer sharedServer] startOnPort:9900 completionBlock:^{
        self.portLabel.stringValue = [[NSNumber numberWithInteger:port] stringValue];
        self.commandTextField.stringValue = [NSString stringWithFormat:@"psql -p %d", port];
    }];    
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    NSLog(@"applicationWillTerminate");
    [[PostgresServer sharedServer] stop];
}

@end
