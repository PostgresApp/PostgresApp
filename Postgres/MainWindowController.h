//
//  MainWindowController.h
//  Postgres
//
//  Created by Chris on 17/05/16.
//
//

#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController

@property (nonatomic) NSMutableArray *servers;
@property IBOutlet NSArrayController *serverArrayController;
@property IBOutlet NSTextView *logTextView;
@property IBOutlet NSBox *databasesContentBox;

- (IBAction)addServer:(id)sender;
- (IBAction)removeServer:(id)sender;
- (IBAction)openPathFolder:(id)sender;
- (IBAction)openLogfile:(id)sender;
- (IBAction)openPsql:(id)sender;
- (IBAction)pg_dump:(id)sender;
- (IBAction)pg_restore:(id)sender;
- (IBAction)startServer:(id)sender;
- (IBAction)stopServer:(id)sender;

@end
