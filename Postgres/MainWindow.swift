//
//  MainWindow.swift
//  Postgres
//
//  Created by Chris on 22/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
	
	dynamic var mainWindowModel: MainWindowModel! {
		didSet {
			func propagate(_ mainWindowModel: MainWindowModel, toChildrenOf parent: NSViewController) {
				if var consumer = parent as? MainWindowModelConsumer {
					consumer.mainWindowModel = mainWindowModel
				}
				for child in parent.childViewControllers {
					propagate(mainWindowModel, toChildrenOf: child)
				}
			}
			propagate(mainWindowModel, toChildrenOf: self.contentViewController!)
		}
	}
	
	
	override func windowDidLoad() {
		super.windowDidLoad()
		
		guard let window = self.window else { return }
		window.titleVisibility = .hidden
		window.styleMask = [window.styleMask, NSFullSizeContentViewWindowMask]
		window.titlebarAppearsTransparent = true
		window.isMovableByWindowBackground = true
		
		let model = MainWindowModel()
		model.sidebarVisible = model.serverManager.servers.count > 1
		mainWindowModel = model
	}
	
	
	func windowWillClose(_ notification: Notification) {
		NSApp.terminate(nil)
	}
}
