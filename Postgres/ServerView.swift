//
//  ServerView.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class ServerViewController: NSViewController, MainWindowModelConsumer {
	
	dynamic var mainWindowModel: MainWindowModel!
	
	@IBOutlet var serverArrayController: NSArrayController!
	@IBOutlet var databaseArrayController: NSArrayController!
	@IBOutlet var databaseCollectionView: NSCollectionView!
	@IBOutlet var toggleSidebarButton: NSButton!
	
	private var settingsWindowControllers: [SettingsWindowController] = []
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.databaseCollectionView.itemPrototype = self.storyboard?.instantiateController(withIdentifier: "DatabaseCollectionViewItem") as? NSCollectionViewItem
	}
	
	
	@IBAction func startServer(_ sender: AnyObject?) {
		guard let server = self.serverArrayController.selectedObjects.first as? Server else { return }
		server.start { (actionStatus) in
			if case let .Failure(error) = actionStatus {
				self.presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
			}
		}
	}
	
	
	@IBAction func stopServer(_ sender: AnyObject?) {
		guard let server = self.serverArrayController.selectedObjects.first as? Server else { return }
		server.stop { (actionStatus) in
			if case let .Failure(error) = actionStatus {
				self.presentError(error, modalFor: self.view.window!, delegate: self, didPresent: nil, contextInfo: nil)
			}
		}
	}
	
	
	@IBAction func openServerSettings(_ sender: AnyObject?) {
		guard let server = self.serverArrayController.selectedObjects.first as? Server else { return }
		
		var oldController: NSWindowController?
		
		for wc in self.settingsWindowControllers {
			if wc.server == server {
				if wc.window!.isVisible {
					wc.showWindow(nil)
					return
				} else {
					oldController = wc
				}
			}
		}
		
		if let windowController = (oldController ?? self.storyboard?.instantiateController(withIdentifier: "SettingsWindow")) as? SettingsWindowController {
			windowController.server = server
			self.settingsWindowControllers.append(windowController)
			
			let newWindow = windowController.window!
			var newWindowFrame = newWindow.frame
			newWindowFrame.origin = self.view.window!.frame.origin
			newWindow.setFrameOrigin(newWindowFrame.origin)
			let visibleFrame = newWindow.screen!.visibleFrame
			
			for window in NSApp.windows {
				if window == newWindow { continue }
				let windowFrame = window.frame
				if windowFrame.minX == newWindowFrame.minX && windowFrame.maxY == newWindowFrame.maxY {
					newWindowFrame.origin.x += 20
					newWindowFrame.origin.y -= 20
					if newWindowFrame.maxX >= visibleFrame.maxX {
						newWindowFrame.origin.x = 20
						newWindowFrame.origin.y = visibleFrame.maxY - 20 - newWindowFrame.height;
					}
					if newWindowFrame.minY <= visibleFrame.minY {
						newWindowFrame.origin.y = visibleFrame.minY
					}
					newWindow.setFrameOrigin(newWindowFrame.origin)
				}
			}
			
			windowController.showWindow(nil)
		}
	}
	
	
	@IBAction func openPsql(_ sender: AnyObject?) {
		guard let server = self.serverArrayController.selectedObjects.first as? Server else { return }
		guard let database = self.databaseArrayController.selectedObjects.first as? Database else { return }
		
		let psqlScript = String(format: "'%@/psql' -p%u -d %@", arguments: [server.binPath.replacingOccurrences(of: "'", with: "'\\''"), server.port, database.name])
		
		let wrapper = ASWrapper(fileName: "ASSubroutines")
		do {
			try wrapper.runSubroutine("openTerminalApp", parameters: [psqlScript])
		} catch {}
	}
	
}



class ServerViewBackgroundView: NSView {
	
	override var isOpaque: Bool { return true }
	override var mouseDownCanMoveWindow: Bool { return true }
	
	override func draw(_ dirtyRect: NSRect) {
		NSColor.white().setFill()
		NSRectFill(dirtyRect)
		
		let x: CGFloat = 20, y: CGFloat = 20
		let imageRect = NSRect(x: x, y: self.bounds.maxY-y-128, width: 128, height: 128)
		if imageRect.intersects(dirtyRect) {
			NSApp.applicationIconImage.draw(in: imageRect)
		}
	}
	
}
