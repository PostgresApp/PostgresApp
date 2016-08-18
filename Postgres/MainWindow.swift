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
		if let window = self.window {
			window.titleVisibility = .hidden
			window.styleMask = [window.styleMask, NSFullSizeContentViewWindowMask]
			window.titlebarAppearsTransparent = true
			window.isMovableByWindowBackground = true
		}
		
		mainWindowModel = MainWindowModel()
		self.addObserver(self, forKeyPath: "mainWindowModel.sidebarVisible", options: [.new], context: nil)
		
		super.windowDidLoad()
	}
	
	
	deinit {
		self.removeObserver(self, forKeyPath: "mainWindowModel.sidebarVisible", context: nil)
	}
	
	
	func windowWillClose(_ notification: Notification) {
		NSApp.terminate(nil)
	}
	
	
	override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
		switch keyPath {
		case .some("mainWindowModel.sidebarVisible"):
			self.invalidateRestorableState()
		default:
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
	
	
	override func encodeRestorableState(with coder: NSCoder) {
		super.encodeRestorableState(with: coder)
		coder.encode(mainWindowModel.sidebarVisible, forKey: "SidebarVisible")
	}
	
	override func restoreState(with coder: NSCoder) {
		mainWindowModel.sidebarVisible = coder.decodeBool(forKey: "SidebarVisible")
		super.restoreState(with: coder)
	}
	
}
