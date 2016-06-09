//
//  PGRestoreController.m
//  Postgres
//
//  Created by Chris on 09/06/16.
//
//

#import "PGRestoreController.h"
#import "PGRestoreTask.h"
#import "PostgresServer.h"

@interface PGRestoreController ()
@property PostgresServer *server;
@property NSWindow *parentWindow;
@property PGRestoreTask *restoreTask;
@property ProgressSheetController *progressSheetController;
@end


@implementation PGRestoreController

- (id)initWithServer:(PostgresServer *)server {
	self = [super initWithWindowNibName:@"PGRestore"];
	if (self) {
		self.server = server;
		self.progressSheetController = [[ProgressSheetController alloc] initWithWindowNibName:@"ProgressSheet"];
		self.progressSheetController.delegate = self;
	}
	return self;
}


- (void)startModalForWindow:(NSWindow *)window {
	self.parentWindow = window;
	
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	openPanel.canChooseDirectories = NO;
	openPanel.canChooseFiles = YES;
	openPanel.allowsMultipleSelection = NO;
	openPanel.resolvesAliases = YES;
	
	[openPanel beginSheetModalForWindow:self.parentWindow completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) {
			[openPanel close];
			
			self.dbName = [[openPanel.URL.path lastPathComponent] stringByDeletingPathExtension];
			
			[self.parentWindow beginSheet:self.window completionHandler:^(NSModalResponse returnCode) {
				if (returnCode == NSModalResponseOK) {
					self.progressSheetController.message = @"Restoring database...";
					[self.parentWindow beginSheet:self.progressSheetController.window completionHandler:NULL];
					
					self.restoreTask = [[PGRestoreTask alloc] init];
					self.restoreTask.server = self.server;
					self.restoreTask.dbName = self.dbName;
					self.restoreTask.filePath = openPanel.URL.path;
					[self.restoreTask startWithCompletionHandler:^(BOOL success, NSError *error) {
						[self.parentWindow endSheet:self.progressSheetController.window];
						if (!success) {
							[self.parentWindow presentError:error modalForWindow:self.parentWindow delegate:nil didPresentSelector:NULL contextInfo:NULL];
						}
					}];
				}
			}];
		}
	}];
}



#pragma mark - IBActions

- (IBAction)ok:(id)sender {
	[self.parentWindow endSheet:self.window returnCode:NSModalResponseOK];
}

- (IBAction)cancel:(id)sender {
	[self.parentWindow endSheet:self.window returnCode:NSModalResponseCancel];
}



#pragma mark - ProgressSheetControllerDelegate

- (void)progressSheetCancel:(id)sender {
	[self.restoreTask cancel];
	[self.parentWindow endSheet:self.progressSheetController.window];
}

@end
