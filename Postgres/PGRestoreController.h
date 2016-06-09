//
//  PGRestoreController.h
//  Postgres
//
//  Created by Chris on 09/06/16.
//
//

#import <Cocoa/Cocoa.h>
#import "ProgressSheetController.h"

@class PostgresServer;

@interface PGRestoreController : NSWindowController <ProgressSheetControllerDelegate>

@property NSString *dbName;

- (id)initWithServer:(PostgresServer *)server;
- (void)startModalForWindow:(NSWindow *)window;

- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;

@end
