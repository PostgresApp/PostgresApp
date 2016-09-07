//
//  ServerView.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class ServerViewController: NSViewController, MainWindowModelConsumer {
	
	@IBOutlet var databaseCollectionView: NSCollectionView!
	
	dynamic var mainWindowModel: MainWindowModel!
	private var settingsWindowControllers: [SettingsWindowController] = []
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		databaseCollectionView.itemPrototype = self.storyboard?.instantiateController(withIdentifier: "DatabaseCollectionViewItem") as? NSCollectionViewItem
	}
	
	
	@IBAction func startServer(_ sender: AnyObject?) {
		guard let server = mainWindowModel.firstSelectedServer else { return }
		server.start { (actionStatus) in
			if case let .Failure(error) = actionStatus {
				self.presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
			}
		}
	}
	
	
	@IBAction func stopServer(_ sender: AnyObject?) {
		guard let server = mainWindowModel.firstSelectedServer else { return }
		server.stop { (actionStatus) in
			if case let .Failure(error) = actionStatus {
				self.presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
			}
		}
	}
	
	
	@IBAction func openServerSettings(_ sender: AnyObject?) {
		guard let server = mainWindowModel.firstSelectedServer else { return }
		
		var oldController: NSWindowController?
		
		for wc in settingsWindowControllers {
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
			settingsWindowControllers.append(windowController)
			
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
		guard let server = mainWindowModel.firstSelectedServer else { return }
		guard let database = server.firstSelectedDatabase else { return }
		
		let clientApp = "iTerm"
		let routine = "open_\(clientApp)"
		var param: String!
		
		switch clientApp {
		case "Terminal", "iTerm":
			param = String(format: "'%@/psql' -p%u -d %@", arguments: [server.binPath.replacingOccurrences(of: "'", with: "'\\''"), server.port, database.name])
		case "Postico":
			param = "postgres://localhost:\(server.port)/chris?nickname=Postgres+(\(database.name))"
		default:
			return
		}
		
		let launcher = ClientLauncher()
		do {
			try launcher.runSubroutine(routine, parameters: [param])
		} catch let error {
			self.presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
		}
	}
	
}



class ServerViewBackgroundView: NSView {
	
	override var isOpaque: Bool { return true }
	override var mouseDownCanMoveWindow: Bool { return true }
	
	override func draw(_ dirtyRect: NSRect) {
		NSColor.white.setFill()
		NSRectFill(dirtyRect)
		
		let x: CGFloat = 20, y: CGFloat = 20
		let imageRect = NSRect(x: x, y: self.bounds.maxY-y-128, width: 128, height: 128)
		if imageRect.intersects(dirtyRect) {
			NSApp.applicationIconImage.draw(in: imageRect)
		}
	}
	
}
