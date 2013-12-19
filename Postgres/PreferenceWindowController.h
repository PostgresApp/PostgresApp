//
//  PreferencesWindowController.h
//  Postgres
//
//  Created by Jakob Egger on 18.12.13.
//
//

#import <Cocoa/Cocoa.h>

@interface PreferenceWindowController : NSWindowController<NSWindowDelegate> {
	IBOutlet NSButton *loginItemCheckbox;
}

+(PreferenceWindowController*)sharedController;

-(IBAction)toggleLoginItem:(id)sender;

-(IBAction)openDataDirectory:(id)sender;
-(IBAction)chooseDataDirectory:(id)sender;
-(IBAction)resetDataDirectory:(id)sender;

@end
