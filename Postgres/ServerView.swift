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
	
	@objc dynamic var mainWindowModel: MainWindowModel!
	
	
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
        
        if clientApp == "Postico" {
            var urlComponents = URLComponents()
            urlComponents.scheme = "postico"
            urlComponents.host = "localhost"
            urlComponents.port = Int(server.port)
            urlComponents.path = "/" + database.name
            let url = urlComponents.url!
            let success = NSWorkspace.shared.open(url)
            if !success {
                let alert = NSAlert()
                alert.messageText = "Could not open Postico"
                alert.informativeText = "Please make sure that you have the latest version of Postico installed, or choose a different client in the preferences"
                if let window = sender?.window {
                    alert.beginSheetModal(for: window, completionHandler: nil)
                } else {
                    alert.runModal()
                }
            }
            return
        }
        else if clientApp == "Terminal" || clientApp == "iTerm" {
            let psql_command = "\(server.binPath)/psql -p\(server.port) \"\(database.name)\""
            let routine = "open_"+clientApp
            do {
                let launcher = ClientLauncher()
                try launcher.runSubroutine(routine, parameters: [psql_command])
            } catch {
                let alert = NSAlert()
                alert.messageText = "Could not open \(clientApp)"
                alert.informativeText =
                """
                Make sure that Postgres.app has permission to automate \(clientApp).
                
                Alternatively, you can also just execute the following command manually to connect to the database:
                \(psql_command)
                """
                if let window = sender?.window {
                    alert.beginSheetModal(for: window, completionHandler: nil)
                } else {
                    alert.runModal()
                }
            }
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
		NSColor.controlBackgroundColor.setFill()
		dirtyRect.fill()
		
		let imgSize = CGFloat(96)
		let x = CGFloat(self.bounds.maxX-imgSize-20), y = CGFloat(20)
		let imageRect = NSRect(x: x, y: self.bounds.maxY-y-imgSize, width: imgSize, height: imgSize)
		if imageRect.intersects(dirtyRect) {
			NSApp.applicationIconImage.draw(in: imageRect)
		}
	}
}



