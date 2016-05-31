//
//  MainWindowController.h
//  Postgres
//
//  Created by Chris on 17/05/16.
//
//

#import <Cocoa/Cocoa.h>


@interface MainWindowController : NSWindowController

@property NSMutableArray *serverArray;
@property IBOutlet NSArrayController *serverArrayController;
@property IBOutlet NSTextView *logTextView;

- (IBAction)addServer:(id)sender;
- (IBAction)removeServer:(id)sender;
- (IBAction)openPathFolder:(id)sender;
- (IBAction)openPsql:(id)sender;
- (IBAction)startServer:(id)sender;
- (IBAction)stopServer:(id)sender;

@end
