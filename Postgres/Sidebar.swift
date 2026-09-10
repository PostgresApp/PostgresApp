//
//  Sidebar.swift
//  Postgres
//
//  Created by Chris on 23/06/16.
//  This code is released under the terms of the PostgreSQL License.
//

import Cocoa

class SidebarController: NSViewController {
	
	@objc dynamic var mainWindowModel: MainWindowModel { MainWindowModel.shared }

	@IBOutlet weak var serverTableView: NSTableView?
	
	@IBAction func removeServer(_ sender: AnyObject?) {
		let server: Server
		if let clickedRow = serverTableView?.clickedRow, clickedRow != -1 {
			server = mainWindowModel.serverManager.servers[clickedRow]
		} else if let selectedServer = mainWindowModel.firstSelectedServer {
			server = selectedServer
		} else {
			NSSound.beep()
			return
		}
		let alert = NSAlert()
		alert.messageText = "Do you want to remove the server \"\(server.name)\" from the sidebar?"
		alert.informativeText = "Postgres.app will not delete the data directory."
		alert.addButton(withTitle: "Remove Server")
		alert.addButton(withTitle: "Cancel")
		alert.beginSheetModal(for: self.view.window!) { (modalResponse) in
			if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
				if server.running {
					try? server.stopSync()
				}
				self.mainWindowModel.removeSelectedServer()
				NotificationCenter.default.post(name: Server.PropertyChangedNotification, object: nil)
			}
		}
	}
	
	var newServerObserver: AnyObject?
	override func viewDidLoad() {
		newServerObserver = NotificationCenter.default.addObserver(forName: Server.NewServerCreatedNotification, object: nil, queue: .main) { [weak self] note in
			let server = note.object as! Server
			if let index = self?.mainWindowModel.serverManager.servers.firstIndex(of: server) {
				self?.serverTableView?.scrollRowToVisible(index)
			}
		}
		super.viewDidLoad()
	}
	
	deinit {
		if let newServerObserver { NotificationCenter.default.removeObserver(newServerObserver) }
	}
}



class ServerIconImageCell: NSImageCell {
	
	override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
		if self.backgroundStyle == .dark {
			super.draw(withFrame: cellFrame, in: controlView)
		} else {
			self.image?.draw(in: cellFrame)
		}
	}
}
