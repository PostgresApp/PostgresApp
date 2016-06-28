//
//  MainViewController.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, PostgresServerManagerConsumer {
	
	dynamic var serverManager: ServerManager!
	
	
	@IBAction func startServer(_ sender: AnyObject?) {
		serverManager.selected()?.start { (actionStatus) in
			if case let .Failure(error) = actionStatus {
				self.presentError(error, modalFor: self.view.window!, delegate: self, didPresent: nil, contextInfo: nil)
			}
		}
	}
	
	@IBAction func stopServer(_ sender: AnyObject?) {
		serverManager.selected()?.stop { (actionStatus) in
			if case let .Failure(error) = actionStatus {
				self.presentError(error, modalFor: self.view.window!, delegate: self, didPresent: nil, contextInfo: nil)
			}
		}
	}
	
	
	override func prepare(for segue: NSStoryboardSegue, sender: AnyObject?) {
		if var target = segue.destinationController as? PostgresServerManagerConsumer {
			target.serverManager = serverManager
		}
	}
	
	
	override func presentError(_ error: NSError, modalFor window: NSWindow, delegate: AnyObject?, didPresent didPresentSelector: Selector?, contextInfo: UnsafeMutablePointer<Void>?) {
super.presentError(error, modalFor: window, delegate: delegate, didPresent: didPresentSelector, contextInfo: contextInfo)
		
		//		let alert = NSAlert(error: error)
//		alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
//
//		if let rawCommandOutput = error.userInfo["RawCommandOutput"] as? String {
//			let accessoryView = NSTextView.init(frame: NSMakeRect(0,0,100,100))
//			accessoryView.textStorage?.mutableString.setString(rawCommandOutput)
//		}
//		self.performSegue(withIdentifier: "showError", sender: error)
	}
	
//	func prepare(for segue: NSStoryboardSegue, sender: AnyObject?) {
//		<#code#>
//	}
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
	
	override var isOpaque: Bool { return true }
	override var mouseDownCanMoveWindow: Bool { return true }
	
	override func draw(_ dirtyRect: NSRect) {
		NSColor.white().setFill()
		NSRectFill(dirtyRect)
		
		let imageRect = NSRect(x: 20, y: self.bounds.maxY-20-128, width: 128, height: 128)
		if imageRect.intersects(dirtyRect) {
			NSApp.applicationIconImage.draw(in: imageRect)
		}
	}
	
	
}
