//
//  AppDelegate.h
//  PostgreSQL
//
//  Created by Mattt Thompson on 12/04/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PostgresStatusMenuItemViewController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) IBOutlet PostgresStatusMenuItemViewController *postgresStatusMenuItemViewController;

@property (weak) IBOutlet NSMenu *statusBarMenu;
@property (weak) IBOutlet NSMenuItem *postgresStatusMenuItem;
@property (weak) IBOutlet NSMenuItem *automaticallyOpenDocumentationMenuItem;
@property (weak) IBOutlet NSMenuItem *automaticallyStartMenuItem;

- (IBAction)selectPostgresStatus:(id)sender;
- (IBAction)selectAbout:(id)sender;
- (IBAction)selectDocumentation:(id)sender;
- (IBAction)selectAutomaticallyOpenDocumentation:(id)sender;
- (IBAction)selectAutomaticallyStart:(id)sender;

@end
