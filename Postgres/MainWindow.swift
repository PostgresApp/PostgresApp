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
	
	var modelObserver: KeyValueObserver!
	
	
	override func windowDidLoad() {
		guard let window = self.window else { return }
		window.titleVisibility = .hidden
		window.styleMask = [window.styleMask, NSFullSizeContentViewWindowMask]
		window.titlebarAppearsTransparent = true
		window.isMovableByWindowBackground = true
		
		let model = MainWindowModel()
		model.sidebarVisible = model.serverManager.servers.count > 1
		mainWindowModel = model
		
		modelObserver = self.observe("mainWindowModel.sidebarVisible") { [weak self] _ in
			guard let this = self else { return }
			this.invalidateRestorableState()
		}
		
		super.windowDidLoad()
	}
	
	
	override func encodeRestorableState(with coder: NSCoder) {
		super.encodeRestorableState(with: coder)
		coder.encode(mainWindowModel.sidebarVisible, forKey: "SidebarVisible")
	}
	
	override func restoreState(with coder: NSCoder) {
		mainWindowModel.sidebarVisible = coder.decodeBool(forKey: "SidebarVisible")
		super.restoreState(with: coder)
	}
	
	
	func windowWillClose(_ notification: Notification) {
		NSApp.terminate(nil)
	}
}
