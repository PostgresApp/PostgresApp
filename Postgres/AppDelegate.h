// AppDelegate.h
//
// Created by Mattt Thompson (http://mattt.me/)
// Copyright (c) 2012 Heroku (http://heroku.com/)
//
// Portions Copyright (c) 1996-2012, The PostgreSQL Global Development Group
// Portions Copyright (c) 1994, The Regents of the University of California
//
// Permission to use, copy, modify, and distribute this software and its
// documentation for any purpose, without fee, and without a written agreement
// is hereby granted, provided that the above copyright notice and this
// paragraph and the following two paragraphs appear in all copies.
//
// IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
// DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
// LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
// EVEN IF THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.
//
// THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
// FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN
// "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATIONS TO
// PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

#import <Cocoa/Cocoa.h>

@class PostgresStatusMenuItemViewController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong) IBOutlet PostgresStatusMenuItemViewController *postgresStatusMenuItemViewController;

@property (weak) IBOutlet NSMenu *statusBarMenu;
@property (weak) IBOutlet NSMenuItem *postgresStatusMenuItem;
@property (weak) IBOutlet NSMenuItem *automaticallyOpenDocumentationMenuItem;
@property (weak) IBOutlet NSMenuItem *automaticallyStartMenuItem;
@property (weak) IBOutlet NSMenuItem *checkForUpdatesMenuItem;

- (IBAction)selectAbout:(id)sender;
- (IBAction)selectDocumentation:(id)sender;
- (IBAction)selectPsql:(id)sender;
- (IBAction)selectAutomaticallyOpenDocumentation:(id)sender;
- (IBAction)selectAutomaticallyStart:(id)sender;
- (IBAction)checkForUpdates:(id)sender;

@end
