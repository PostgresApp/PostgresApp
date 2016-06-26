//
//  MainWindowController.swift
//  Postgres
//
//  Created by Chris on 22/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

protocol PostgresServerManagerConsumer {
	var serverManager: ServerManager? { get set }
}

class MainWindowController: NSWindowController {
	
	override func windowDidLoad() {
		serverManager = ServerManager.shared
		super.windowDidLoad()
	}
	
	var serverManager: ServerManager? {
		didSet {
			func propagate(_ serverManager: ServerManager?, toChildrenOf parent: NSViewController) {
				if var consumer = parent as? PostgresServerManagerConsumer {
					consumer.serverManager = serverManager
				}
				for child in parent.childViewControllers {
					propagate(serverManager, toChildrenOf: child)
				}
			}
			
			propagate(serverManager, toChildrenOf: self.contentViewController!)
		}
	}
	
	
	
	
	// MARK - IBActions
	
	@IBAction func addServer(_ sender: AnyObject) {
		
	}
	
	@IBAction func removeServer(_ sender: AnyObject) {
		let alert = NSAlert()
		alert.messageText = "Delete Server?"
		alert.addButton(withTitle: "OK")
		alert.addButton(withTitle: "Cancel")
		alert.alertStyle = .warning
		alert.beginSheetModal(for: self.window!) { (modalResponse) -> Void in
			if modalResponse == NSAlertFirstButtonReturn {
				print("OK")
				self.serverManager?.removeSelectedServer()
			}
		}
		
	}
	
	
	
	
	/*
	- (IBAction)removeServer:(id)sender {
	NSAlert *alert = [NSAlert alertWithMessageText:@"Delete server?" defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
	
	[alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
	if (returnCode == NSModalResponseOK) {
	NSUInteger selIdx = self.serverArrayController.selectionIndex;
	
	if ([[self.servers objectAtIndex:selIdx] isRunning]) {
	[[self.servers objectAtIndex:selIdx] stopWithCompletionHandler:^(BOOL success, NSError *error) {
	if (!success) {
	[self presentError:error modalForWindow:self.window delegate:nil didPresentSelector:NULL contextInfo:NULL];
	}
	}];
	}
	
	[self.servers removeObjectAtIndex:selIdx];
	[self.serverArrayController rearrangeObjects];
	if (selIdx == self.servers.count) {
	[self.serverArrayController setSelectionIndex:selIdx-1];
	} else {
	[self.serverArrayController setSelectionIndex:selIdx];
	}
	}
	}];
	}

*/
	
}
