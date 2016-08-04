//
//  MainViewController.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, ServerManagerConsumer {
	
	dynamic var serverManager: ServerManager!
	
	@IBOutlet var serverArrayController: NSArrayController?
	@IBOutlet var databaseArrayController: NSArrayController?
	@IBOutlet var databaseCollectionView: NSCollectionView?
	@IBOutlet var toggleSidebarButton: NSButton!
	
	private var settingsWindowControllers: [SettingsWindowController] = []
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.databaseCollectionView?.itemPrototype = self.storyboard?.instantiateController(withIdentifier: "DatabaseCollectionViewItem") as? NSCollectionViewItem
	}
	
	
	@IBAction func startServer(_ sender: AnyObject?) {
		guard let server = self.serverArrayController?.selectedObjects.first as? Server else { return }
		server.start { (actionStatus) in
			if case let .Failure(error) = actionStatus {
				self.presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
			}
		}
	}
	
	
	@IBAction func stopServer(_ sender: AnyObject?) {
		guard let server = self.serverArrayController?.selectedObjects.first as? Server else { return }
		server.stop { (actionStatus) in
			if case let .Failure(error) = actionStatus {
				self.view.window?.windowController?.presentError(error, modalFor: self.view.window!, delegate: self, didPresent: nil, contextInfo: nil)
			}
		}
	}
	
	
	@IBAction func openServerSettings(_ sender: AnyObject?) {
		guard let server = self.serverArrayController?.selectedObjects.first as? Server else { return }
		
		for wc in self.settingsWindowControllers {
			if wc.server == server {
				wc.showWindow(self)
				return
			}
		}
		
		if let newWinCtrlr = self.storyboard?.instantiateController(withIdentifier: "SettingsWindow") as? SettingsWindowController {
			newWinCtrlr.server = server
			self.settingsWindowControllers.append(newWinCtrlr)
			newWinCtrlr.showWindow(nil)
		}
		
	}
	
	
	@IBAction func openPsql(_ sender: AnyObject?) {
		guard let server = self.serverArrayController?.selectedObjects.first as? Server else { return }
		guard let database = self.databaseArrayController?.selectedObjects.first as? Database else { return }
		
		let psqlScript = String(format: "'%@/psql' -p%u -d %@", arguments: [server.binPath.replacingOccurrences(of: "'", with: "'\\''"), server.port, database.name])
		
		let wrapper = ASWrapper(fileName: "ASSubroutines")
		do {
			try wrapper.runSubroutine("openTerminalApp", parameters: [psqlScript])
		} catch {}
	}
	
	
	override func prepare(for segue: NSStoryboardSegue, sender: AnyObject?) {
		if var target = segue.destinationController as? ServerManagerConsumer {
			target.serverManager = self.serverManager
		}
	}
}



class MainViewBackgroundView: NSView {
	
	override var isOpaque: Bool { return true }
	override var mouseDownCanMoveWindow: Bool { return true }
	
	override func draw(_ dirtyRect: NSRect) {
		NSColor.white().setFill()
		NSRectFill(dirtyRect)
		
		let xPos: CGFloat = 20, yPos: CGFloat = 20
		let imageRect = NSRect(x: xPos, y: self.bounds.maxY-yPos-128, width: 128, height: 128)
		if imageRect.intersects(dirtyRect) {
			NSApp.applicationIconImage.draw(in: imageRect)
		}
	}
	
}
