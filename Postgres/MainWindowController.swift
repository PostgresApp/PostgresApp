//
//  MainWindowController.swift
//  Postgres
//
//  Created by Chris on 22/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
	
	var serverManager: ServerManager! {
		didSet {
			func propagate(_ serverManager: ServerManager, toChildrenOf parent: NSViewController) {
				if var consumer = parent as? ServerManagerConsumer {
					consumer.serverManager = serverManager
				}
				for child in parent.childViewControllers {
					propagate(serverManager, toChildrenOf: child)
				}
			}
			propagate(serverManager, toChildrenOf: self.contentViewController!)
		}
	}
	
	
	override func windowDidLoad() {
		self.serverManager = ServerManager.shared
		
		if let window = self.window {
			window.titleVisibility = .hidden
			window.styleMask = [window.styleMask, NSFullSizeContentViewWindowMask]
			window.titlebarAppearsTransparent = true
			window.isMovableByWindowBackground = true
		}
		
		super.windowDidLoad()
	}
	
	
	override func presentError(_ error: NSError, modalFor window: NSWindow, delegate: AnyObject?, didPresent didPresentSelector: Selector?, contextInfo: UnsafeMutablePointer<Void>?) {
		print("MainWindowController's presentError() called")
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
	
	func errorDidPresent(_: AnyObject) {
		print("errorDidPresent")
	}
}
