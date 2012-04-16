//
//  AppDelegate.m
//  Postgres-Helper
//
//  Created by Mattt Thompson on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [[NSWorkspace sharedWorkspace] launchApplication:@"/Applications/Postgres.app"];
}

@end
