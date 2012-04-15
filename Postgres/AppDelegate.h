//
//  AppDelegate.h
//  PostgreSQL
//
//  Created by Mattt Thompson on 12/04/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSMenu *statusBarMenu;
@property (weak) IBOutlet NSMenuItem *postgresStatusMenuItem;

- (IBAction)selectPostgresStatus:(id)sender;
- (IBAction)selectAbout:(id)sender;
- (IBAction)selectDocumentation:(id)sender;
- (IBAction)selectAutomaticallyStart:(id)sender;

@end
