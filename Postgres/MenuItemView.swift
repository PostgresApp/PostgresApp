//
//  MenuItemView.swift
//  Postgres
//
//  Created by Chris on 09/08/2016.
//  This code is released under the terms of the PostgreSQL License.
//

import Cocoa

class MenuItemViewController: NSViewController {
	
	@objc dynamic var server: Server!
	
	@objc dynamic private(set) var errorIconVisible = false
	@objc dynamic private(set) var errorTooltip = ""
	
	
	convenience init?(_ server: Server) {
		self.init(nibName: "MenuItemView", bundle: nil)
		self.server = server
	}
	
	
	@IBAction func serverAction(_ sender: AnyObject?) {
		if !server.running {
			server.start(serverActionCompleted)
		} else {
			server.stop(serverActionCompleted)
		}
	}
	
	
	private func serverActionCompleted(result: Result<Void, Error>) {
		if case let .failure(error) = result {
			self.errorIconVisible = true
			self.errorTooltip = error.localizedDescription
		} else {
			self.errorIconVisible = false
			self.errorTooltip = ""
		}
		
		DistributedNotificationCenter.default().post(name: Server.StatusChangedNotification, object: nil)
	}
	
}



class MenuItemView: NSView {
	// This subclass is only needed to detect menu items with custom views
}
