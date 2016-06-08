//
//  AddServerSheetController.h
//  Postgres
//
//  Created by Chris on 24/05/16.
//
//

#import <Cocoa/Cocoa.h>
#import "PostgresServer.h"


@interface AddServerSheetController : NSWindowController

@property NSString *name;
@property NSString *varPath;
@property NSUInteger port;
@property NSArray *versions;
@property NSUInteger selectedVersionIndex;

@property (readonly, nonatomic) NSString *version;
@property (readonly) PostgresServer *server;

@property IBOutlet NSPopUpButton *versionsPopup;

- (IBAction)openChooseFolder:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;

@end
