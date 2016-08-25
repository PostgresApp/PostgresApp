//
//  MenuItemView.swift
//  Postgres
//
//  Created by Chris on 09/08/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class MenuItemViewController: NSViewController {
	
	dynamic var server: Server?
	dynamic private(set) var image: NSImage!
	dynamic private(set) var showErrorImage = false
	dynamic private(set) var errorTooltip = ""
	var keyValueObserver: KeyValueObserver!
	
	
	override func awakeFromNib() {
		keyValueObserver = self.observe("server.serverStatus", options: .initial) { [weak self] _ in
			guard let server = self?.server else { return }
			switch server.serverStatus {
			case .Unknown:
				self?.image = NSImage(imageLiteralResourceName: NSImageNameStatusNone)
			case .Running:
				self?.image = NSImage(imageLiteralResourceName: NSImageNameStatusAvailable)
			default:
				self?.image = NSImage(imageLiteralResourceName: NSImageNameStatusUnavailable)
			}
		}
	}
	
	
	@IBAction func startServer(_ sender: AnyObject?) {
		guard let server = self.server else { return }
		server.start { (actionStatus) in
			DistributedNotificationCenter.default().post(name: Server.statusChangedNotification, object: nil)
			if case let .Failure(error) = actionStatus {
				self.showErrorImage = true
				self.errorTooltip = error.localizedDescription
			} else {
				self.showErrorImage = false
				self.errorTooltip = ""
			}
		}
	}
	
	
	@IBAction func stopServer(_ sender: AnyObject?) {
		guard let server = self.server else { return }
		server.stop { (actionStatus) in
			DistributedNotificationCenter.default().post(name: Server.statusChangedNotification, object: nil)
			if case let .Failure(error) = actionStatus {
				self.showErrorImage = true
				self.errorTooltip = error.localizedDescription
			} else {
				self.showErrorImage = false
				self.errorTooltip = ""
			}
		}
	}
	
}



class MenuItemView: NSView {
	// This subclass is only needed to detect menu items with custom views
}
