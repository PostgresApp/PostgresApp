//
//  PreferencesWindowController.m
//  Postgres
//
//  Created by Jakob Egger on 18.12.13.
//
//

#import "PreferenceWindowController.h"
#import <ServiceManagement/ServiceManagement.h>
#import "PostgresConstants.h"
#import "PostgresServer.h"

@implementation PreferenceWindowController

+(PreferenceWindowController*)sharedController {
	static PreferenceWindowController* sharedController = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedController = [[PreferenceWindowController alloc] initWithWindowNibName:@"PreferenceWindow"];
	});
	return sharedController;
}

-(void)windowDidLoad {
	[self configureLoginItemButton];
	[dataDirectoryField bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:[PostgresServer dataDirectoryPreferenceKey]] options:nil];
}

-(void)configureLoginItemButton {
	BOOL loginItemEnabled = NO;
	NSArray *jobs = (__bridge_transfer NSArray *)SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
	for (NSDictionary *job in jobs) {
		if ([[job valueForKey:@"Label"] isEqualToString:@"com.postgresapp.PostgresHelper"]) {
			loginItemEnabled = YES;
			break;
		}
	}
	[loginItemCheckbox setState: loginItemEnabled ? NSOnState : NSOffState];
	
	BOOL loginItemSupported = [[NSBundle mainBundle].bundlePath isEqualToString:@"/Applications/Postgres.app"];
	if (loginItemSupported) {
		loginItemCheckbox.target = self;
		loginItemCheckbox.action = @selector(toggleLoginItem:);
	} else {
		loginItemCheckbox.enabled = NO;
	}
}

-(IBAction)toggleLoginItem:(id)sender {
	BOOL loginItemEnabled = (loginItemCheckbox.state == NSOnState);
    
    NSURL *helperApplicationURL = [[NSBundle mainBundle].bundleURL URLByAppendingPathComponent:@"Contents/Library/LoginItems/PostgresHelper.app"];
    if (LSRegisterURL((__bridge CFURLRef)helperApplicationURL, true) != noErr) {
        NSLog(@"LSRegisterURL Failed");
    }
    
    BOOL stateChangeSuccessful = SMLoginItemSetEnabled(CFSTR("com.postgresapp.PostgresHelper"), loginItemEnabled);
	if (!stateChangeSuccessful) {
        NSError *error = [NSError errorWithDomain:@"com.postgresapp.Postgres" code:1 userInfo:@{ NSLocalizedDescriptionKey: @"Failed to set login item."}];
		[self presentError:error modalForWindow:self.window delegate:nil didPresentSelector:NULL contextInfo:NULL];
		loginItemCheckbox.state = loginItemEnabled ? NSOffState : NSOnState;
    }
}


-(IBAction)openDataDirectory:(id)sender;
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] stringForKey:[PostgresServer dataDirectoryPreferenceKey]]]];
}

-(IBAction)chooseDataDirectory:(id)sender;
{
	NSOpenPanel* dataDirPanel = [NSOpenPanel openPanel];
	dataDirPanel.canChooseDirectories = YES;
	dataDirPanel.canChooseFiles = NO;
	dataDirPanel.canCreateDirectories = YES;
	dataDirPanel.directoryURL = [NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] stringForKey:[PostgresServer dataDirectoryPreferenceKey]]];
	[dataDirPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if (result==NSFileHandlingPanelOKButton) {
			[[NSUserDefaults standardUserDefaults] setObject:dataDirPanel.URL.path forKey:[PostgresServer dataDirectoryPreferenceKey]];
		}
	}];
}

-(IBAction)resetDataDirectory:(id)sender;
{
	[[NSUserDefaults standardUserDefaults] setObject:[PostgresServer standardDatabaseDirectory] forKey:[PostgresServer dataDirectoryPreferenceKey]];
}

-(BOOL)windowShouldClose:(NSWindow*)window {
	BOOL controlDidResign = [self.window makeFirstResponder:nil];
	if (!controlDidResign) NSBeep();
	[[NSUserDefaults standardUserDefaults] synchronize];
	return controlDidResign;
}


@end
