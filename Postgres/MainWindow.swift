//
//  MainWindow.swift
//  Postgres
//
//  Created by Chris on 22/06/16.
//  This code is released under the terms of the PostgreSQL License.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
	
	@objc dynamic var mainWindowModel: MainWindowModel { MainWindowModel.shared }
	
	override func windowDidLoad() {
		super.windowDidLoad()
		
		guard let window = self.window else { return }
		window.isMovableByWindowBackground = true
	}
	
}
