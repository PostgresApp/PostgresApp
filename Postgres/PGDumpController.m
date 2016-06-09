//
//  PGDumpController.m
//  Postgres
//
//  Created by Chris on 09/06/16.
//
//

#import "PGDumpController.h"
#import "PGDumpTask.h"
#import "PostgresServer.h"

@interface PGDumpController ()
@property PostgresServer *server;
@property NSWindow *parentWindow;
@property PGDumpTask *dumpTask;
@property ProgressSheetController *progressSheetController;
@end


@implementation PGDumpController

- (id)initWithServer:(PostgresServer *)server dbName:(NSString *)dbName {
	self = [super initWithWindowNibName:@"PGDump"];
	if (self) {
		self.server = server;
		self.dbName = dbName;
		self.progressSheetController = [[ProgressSheetController alloc] initWithWindowNibName:@"ProgressSheet"];
		self.progressSheetController.delegate = self;
	}
	return self;
}


- (void)startModalForWindow:(NSWindow *)window {
	self.parentWindow = window;
	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	savePanel.nameFieldStringValue = [NSString stringWithFormat:@"%@.pg_dump", self.dbName];
	
	[savePanel beginSheetModalForWindow:self.parentWindow completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) {
			[savePanel close];
			
			self.progressSheetController.message = @"Dumping database...";
			[self.parentWindow beginSheet:self.progressSheetController.window completionHandler:NULL];
			
			self.dumpTask = [[PGDumpTask alloc] init];
			self.dumpTask.server = self.server;
			self.dumpTask.dbName = self.dbName;
			self.dumpTask.filePath = savePanel.URL.path;
			[self.dumpTask startWithCompletionHandler:^(BOOL success, NSError *error) {
				[self.parentWindow endSheet:self.progressSheetController.window];
				if (!success) {
					[self.parentWindow presentError:error modalForWindow:self.parentWindow delegate:nil didPresentSelector:NULL contextInfo:NULL];
				}
			}];
		}
	}];
}



#pragma mark - ProgressSheetControllerDelegate

- (void)progressSheetCancel:(id)sender {
	[self.dumpTask cancel];
	[self.parentWindow endSheet:self.progressSheetController.window];
}

@end
