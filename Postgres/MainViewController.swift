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
	
	
	@IBAction func startServer(_ sender: AnyObject?) {
		if let server = serverArrayController?.selectedObjects.first as! Server? {
			server.start { (actionStatus) in
				if case let .Failure(error) = actionStatus {
					self.errorHandler(error: error)
				}
			}
		}
	}
	
	
	@IBAction func stopServer(_ sender: AnyObject?) {
		if let server = serverArrayController?.selectedObjects.first as! Server? {
			server.stop { (actionStatus) in
				if case let .Failure(error) = actionStatus {
					self.view.window?.windowController?.presentError(error, modalFor: self.view.window!, delegate: self, didPresent: nil, contextInfo: nil)
				}
			}
		}
	}
	
	
	private func errorHandler(error: NSError) {
		if let mainWindowController = self.view.window?.windowController {
			mainWindowController.presentError(error, modalFor: mainWindowController.window!, delegate: mainWindowController, didPresent: Selector(("errorDidPresent:")), contextInfo: nil)
		}
	}
	
	
	override func prepare(for segue: NSStoryboardSegue, sender: AnyObject?) {
		if var target = segue.destinationController as? ServerManagerConsumer {
			target.serverManager = serverManager
		}
	}
	
}



class MainViewBackgroundView: NSView {
	
	override var isOpaque: Bool { return true }
	override var mouseDownCanMoveWindow: Bool { return true }
	
	override func draw(_ dirtyRect: NSRect) {
		NSColor.white().setFill()
		NSRectFill(dirtyRect)
		
		let imageRect = NSRect(x: 20, y: self.bounds.maxY-20-128, width: 128, height: 128)
		if imageRect.intersects(dirtyRect) {
			NSApp.applicationIconImage.draw(in: imageRect)
		}
	}
	
	
}
