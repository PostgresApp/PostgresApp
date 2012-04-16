//
//  AppDelegate.m
//  PostgresHelper
//
//  Created by Mattt Thompson on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [[NSWorkspace sharedWorkspace] launchApplication:@"/Applications/Postgres.app"];
//    [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:@"com.heroku.Postgres" options:NSWorkspaceLaunchWithoutAddingToRecents | NSWorkspaceLaunchWithoutActivation | NSWorkspaceLaunchAndHide additionalEventParamDescriptor:nil launchIdentifier:NULL];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [NSApp terminate:self];
    });
}

@end
