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

- (IBAction)openPathFolder:(id)sender;
- (IBAction)openPsql:(id)sender;
- (IBAction)startServer:(id)sender;
- (IBAction)stopServer:(id)sender;

- (void)stopAllServers;

@end
