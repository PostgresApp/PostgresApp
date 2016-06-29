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
		if let server = self.serverArrayController?.selectedObjects.first as! PostgresServer? {
						
			switch server.serverStatus {
			
			case .Running:
				let userInfo: [String: AnyObject] = [
					NSLocalizedDescriptionKey: "This PostgreSQL server is already running on port \(server.port)",
					NSLocalizedRecoverySuggestionErrorKey: "Please stop this server before starting again."
				]
				errorHandler(error: NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo))
				break
				
			case .NoBinDir:
				let userInfo: [String: AnyObject] = [
					NSLocalizedDescriptionKey: "The binaries for this PostgreSQL server were not found",
					NSLocalizedRecoverySuggestionErrorKey: "Create a new Server and try again."
				]
				errorHandler(error: NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo))
				break
				
			case .WrongDataDirectory:
				let userInfo: [String: AnyObject] = [
					NSLocalizedDescriptionKey: "There is already a PostgreSQL server running on port \(server.port)",
					NSLocalizedRecoverySuggestionErrorKey: "Please stop this server before.\n\nIf you want to use multiple servers, configure them to use different ports."
				]
				errorHandler(error: NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo))
				break
				
			case .Error:
				let userInfo: [String: AnyObject] = [
					NSLocalizedDescriptionKey: "Unknown error",
					NSLocalizedRecoverySuggestionErrorKey: ""
				]
				errorHandler(error: NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo))
				break
			
			case .Startable:
				server.start { (actionStatus) in
					if case let .Failure(error) = actionStatus {
						self.errorHandler(error: error)
					}
				}
				break
			}
		}
	}
	
	
	@IBAction func stopServer(_ sender: AnyObject?) {
		if let server = self.serverArrayController?.selectedObjects.first as! PostgresServer? {
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
