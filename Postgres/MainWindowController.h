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
@property IBOutlet NSView *iconViewContainer;
@property IBOutlet NSTextView *logTextView;
@property IBOutlet NSPopover *settingsPopover;

- (IBAction)addServer:(id)sender;
- (IBAction)removeServer:(id)sender;
- (IBAction)openPathFolder:(id)sender;
- (IBAction)openLogInConsole:(id)sender;
- (IBAction)openPsql:(id)sender;
- (IBAction)exportDB:(id)sender;
- (IBAction)restoreDB:(id)sender;
- (IBAction)startServer:(id)sender;
- (IBAction)stopServer:(id)sender;
- (IBAction)showSettings:(id)sender;

@end
