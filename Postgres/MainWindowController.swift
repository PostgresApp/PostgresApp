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
		self.serverManager = ServerManager.shared()
		
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
		
		if let rawCommandOutput = error.userInfo["RawCommandOutput"] as? String {
			// present rawCommandOutput in custom error sheet
			print("Error with rawCommandOutput detected: \(rawCommandOutput)")
		} else {
			super.presentError(error, modalFor: window, delegate: delegate, didPresent: didPresentSelector, contextInfo: contextInfo)
		}
	}
	
	
	func errorDidPresent(_: AnyObject) {
		print("errorDidPresent")
	}
}
