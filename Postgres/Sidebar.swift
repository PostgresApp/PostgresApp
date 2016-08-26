//
//  Sidebar.swift
//  Postgres
//
//  Created by Chris on 23/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class SidebarController: NSViewController, MainWindowModelConsumer {
	
	dynamic var mainWindowModel: MainWindowModel!
	
	
	override func prepare(for segue: NSStoryboardSegue, sender: AnyObject?) {
		if var target = segue.destinationController as? MainWindowModelConsumer {
			target.mainWindowModel = mainWindowModel
		}
	}
	
	
	@IBAction func removeServer(_ sender: AnyObject) {
		let alert = NSAlert()
		alert.messageText = "Do you want to remove the server from the sidebar?"
		alert.informativeText = "Postgres.app will not delete the data directory."
		alert.addButton(withTitle: "Remove Server")
		alert.addButton(withTitle: "Cancel")
		alert.beginSheetModal(for: self.view.window!) { (modalResponse) in
			if modalResponse == NSAlertFirstButtonReturn {
				if let server = self.mainWindowModel.firstSelectedServer {
					server.stop { _ in }
				}
				self.mainWindowModel.removeSelectedServer()
				NotificationCenter.default().post(name: Server.propertyChangedNotification, object: nil)
			}
		}
	}
	
}



class ServerTableCellView: NSTableCellView {
	
	dynamic private(set) var statusImage: NSImage!
	var keyValueObserver: KeyValueObserver!
	
	
	override func awakeFromNib() {
		keyValueObserver = self.observe("objectValue.serverStatus", options: .initial) { [weak self] _ in
			guard let server = self?.objectValue as? Server else { return }
			switch server.serverStatus {
			case .Unknown:
				self?.statusImage = NSImage(imageLiteralResourceName: NSImageNameStatusNone)
			case .Running:
				self?.statusImage = NSImage(imageLiteralResourceName: NSImageNameStatusAvailable)
			default:
				self?.statusImage = NSImage(imageLiteralResourceName: NSImageNameStatusUnavailable)
			}
		}
	}
	
}
