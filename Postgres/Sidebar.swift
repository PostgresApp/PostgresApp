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

	@IBAction func removeServer(_ sender: AnyObject?) {
		guard let server = mainWindowModel.firstSelectedServer else { return }
		
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
