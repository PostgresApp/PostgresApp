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
	
	
	@IBAction func openPsql(_ sender: AnyObject?) {
		guard let server = mainWindowModel.firstSelectedServer else { return }
		guard let database = server.firstSelectedDatabase else { return }
		
		let clientApp = UserDefaults.standard.object(forKey: "ClientAppName") as? String ?? "Terminal"
		guard FileManager.default.applicationExists(clientApp) else {
			let userInfo = [
				NSLocalizedDescriptionKey: "\"\(clientApp)\" not found.",
				NSLocalizedRecoverySuggestionErrorKey: "Please select a different database client in the preferences."
			]
			let error = NSError(domain: "com.postgresapp.Postgres2.missing-client-app", code: 0, userInfo: userInfo)
			self.presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
			return
		}
		
		let routine = "open_"+clientApp
		var param: String
		
		switch clientApp {
		case "Terminal", "iTerm":
			param = String(format: "\"%@/psql\" -p%u -d \"%@\"", arguments: [server.binPath.replacingOccurrences(of: "'", with: "'\\''"), server.port, database.name])
		case "Postico":
			param = String(format: "postgres://localhost:%u/%@", server.port, database.name)
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
	
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if let target = segue.destinationController as? SettingsViewController {
			guard let server = mainWindowModel.firstSelectedServer else { return }
			target.server = server
		}
	}
	
}



class ServerViewBackgroundView: NSView {
	override var isOpaque: Bool { return true }
	override var mouseDownCanMoveWindow: Bool { return true }
	
	override func draw(_ dirtyRect: NSRect) {
		NSColor.white.setFill()
		NSRectFill(dirtyRect)
		
		let imgSize = CGFloat(96)
		let x = CGFloat(self.bounds.maxX-imgSize-20), y = CGFloat(20)
		let imageRect = NSRect(x: x, y: self.bounds.maxY-y-imgSize, width: imgSize, height: imgSize)
		if imageRect.intersects(dirtyRect) {
			NSApp.applicationIconImage.draw(in: imageRect)
		}
	}
}



