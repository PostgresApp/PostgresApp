//
//  PGDumpController.h
//  Postgres
//
//  Created by Chris on 09/06/16.
//
//

#import <Cocoa/Cocoa.h>
#import "ProgressSheetController.h"

@class PostgresServer;

@interface PGDumpController : NSWindowController <ProgressSheetControllerDelegate>

@property NSString *dbName;

- (id)initWithServer:(PostgresServer *)server dbName:(NSString *)dbName;
- (void)startModalForWindow:(NSWindow *)window;

@end
