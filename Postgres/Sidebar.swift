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
	
	@IBOutlet var serverArrayController: NSArrayController!
	
	
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
				if let server = self.serverArrayController.selectedObjects.first as? Server {
					server.stop { _ in }
				}
				self.serverArrayController.remove(nil)
				self.serverArrayController.rearrangeObjects()
				NotificationCenter.default().post(name: Server.changedNotification, object: nil)
			}
		}
	}
	
}



class ServerTableCellView: NSTableCellView {
	
	dynamic private(set) var image: NSImage!
	var keyValueObserver: KeyValueObserver!
	
	
	override func awakeFromNib() {
		keyValueObserver = KeyValueObserver.observe(self, keyPath: "objectValue.running", options: .new) {
			let imgName = (self.objectValue as? Server)?.running == true ? NSImageNameStatusAvailable : NSImageNameStatusUnavailable
			self.image = NSImage(imageLiteralResourceName: imgName)
		}
	}
	
}
