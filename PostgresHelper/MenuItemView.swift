//
//  MenuItemView.swift
//  Postgres
//
//  Created by Chris on 09/08/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class MenuItemViewController: NSViewController {
	
	dynamic var server: Server!
	dynamic private(set) var actionButtonTitle: String?
	dynamic private(set) var statusIcon: NSImage?
	dynamic private(set) var errorIconVisible = false
	dynamic private(set) var errorTooltip = ""
	var keyValueObserver: KeyValueObserver!
	
	
	convenience init?(_ server: Server) {
		self.init(nibName: "MenuItemView", bundle: nil)
		self.server = server
	}
	
	
	override func awakeFromNib() {
		keyValueObserver = self.observe("server.serverStatus", options: .initial) { [weak self] _ in
			guard let this = self else { return }
			switch this.server.serverStatus {
			case .Unknown:
				this.statusIcon = NSImage(imageLiteralResourceName: NSImageNameStatusNone)
				this.actionButtonTitle = "Start"
			case .Running:
				this.statusIcon = NSImage(imageLiteralResourceName: NSImageNameStatusAvailable)
				this.actionButtonTitle = "Stop"
			default:
				this.statusIcon = NSImage(imageLiteralResourceName: NSImageNameStatusUnavailable)
				this.actionButtonTitle = "Start"
			}
		}
	}
	
	
	@IBAction func serverAction(_ sender: AnyObject?) {
		if !server.running {
			server.start(closure: serverActionCompleted)
		} else {
			server.stop(closure: serverActionCompleted)
		}
	}
	
	
	private func serverActionCompleted(actionStatus: Server.ActionStatus) {
		DistributedNotificationCenter.default().post(name: Server.StatusChangedNotification, object: nil)
		if case let .Failure(error) = actionStatus {
			self.errorIconVisible = true
			self.errorTooltip = error.localizedDescription
		} else {
			self.errorIconVisible = false
			self.errorTooltip = ""
		}
	}
	
}



class MenuItemView: NSView {
	// This subclass is only needed to detect menu items with custom views
}
