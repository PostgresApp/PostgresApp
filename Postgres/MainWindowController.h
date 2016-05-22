//
//  MainWindowController.h
//  Postgres
//
//  Created by Chris on 17/05/16.
//
//

#import <Cocoa/Cocoa.h>


@interface MainWindowController : NSWindowController

@property IBOutlet NSArrayController *serverArrayController;
@property NSMutableArray *serverArray;

- (IBAction)openPathFolder:(id)sender;
- (IBAction)openPsql:(id)sender;
- (IBAction)startServer:(id)sender;
- (IBAction)stopServer:(id)sender;
- (IBAction)toggleRunAtStartup:(id)sender;

- (void)stopAllServers;

@end
