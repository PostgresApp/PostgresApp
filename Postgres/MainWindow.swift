//
//  MainWindow.swift
//  Postgres
//
//  Created by Chris on 22/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
	
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
	
	
	func windowWillClose(_ notification: Notification) {
		NSApp.terminate(nil)
	}
	
}
