//
//  MainViewController.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, PostgresServerManagerConsumer {
	
	dynamic var serverManager: ServerManager?
	
	
	@IBAction func startServer(_ sender: AnyObject?) {
		ServerManager.shared.selected().start { (success, error) in
			if !success {
				self.presentError(error!, modalFor: NSApp.mainWindow!, delegate: self, didPresent: nil, contextInfo: nil)
			}
		}
	}
	
	@IBAction func stoptServer(_ sender: AnyObject?) {
		ServerManager.shared.selected().stop { (success, error) in
			if !success {
				self.presentError(error, modalFor: NSApp.mainWindow!, delegate: self, didPresent: nil, contextInfo: nil)
			}
		}
	}
	
	
	/*
	-(void)presentError:(NSError *)error modalForWindow:(NSWindow *)window delegate:(id)delegate didPresentSelector:(SEL)didPresentSelector contextInfo:(void *)contextInfo {
	NSAlert *alert = [NSAlert alertWithError:error];
	
	if (error.userInfo[@"RawCommandOutput"]) {
	NSArray *tlo;
	[[NSBundle mainBundle] loadNibNamed:@"AlertAccessoryView" owner:nil topLevelObjects:&tlo];
	for (id obj in tlo) {
	if ([obj isKindOfClass:[NSScrollView class]]) {
	((NSTextView*)((NSScrollView*)obj).contentView.documentView).textStorage.mutableString.string = error.userInfo[@"RawCommandOutput"];
	alert.accessoryView = obj;
	}
	}
	}
	
	[alert beginSheetModalForWindow:window modalDelegate:delegate didEndSelector:didPresentSelector contextInfo:contextInfo];
	}
	*/
}



class MainViewBackgroundView: NSView {
	
	override func draw(_ dirtyRect: NSRect) {
		NSColor.white().setFill()
		NSRectFill(dirtyRect)
		
		let imageRect = NSRect(x: 20, y: self.bounds.maxY-20-128, width: 128, height: 128)
		if imageRect.intersects(dirtyRect) {
			NSApp.applicationIconImage.draw(in: imageRect)
		}
	}
	
	override var mouseDownCanMoveWindow: Bool {
		return true
	}
	
}
