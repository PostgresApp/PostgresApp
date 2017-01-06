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
	
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if var target = segue.destinationController as? MainWindowModelConsumer {
			target.mainWindowModel = mainWindowModel
		}
	}
	
	
	@IBAction func removeServer(_ sender: AnyObject?) {
		let alert = NSAlert()
		alert.messageText = "Do you want to remove the server from the sidebar?"
		alert.informativeText = "Postgres.app will not delete the data directory."
		alert.addButton(withTitle: "Remove Server")
		alert.addButton(withTitle: "Cancel")
		alert.beginSheetModal(for: self.view.window!) { (modalResponse) in
			if modalResponse == NSAlertFirstButtonReturn {
				if let server = self.mainWindowModel.firstSelectedServer, server.running {
					let _ = server.stopSync()
				}
				self.mainWindowModel.removeSelectedServer()
				NotificationCenter.default.post(name: Server.PropertyChangedNotification, object: nil)
			}
		}
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
