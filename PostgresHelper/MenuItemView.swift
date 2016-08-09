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
	
	dynamic var image: NSImage {
		get {
			var imgName: String
			if let server = self.server {
				imgName = server.running ? NSImageNameStatusAvailable : NSImageNameStatusUnavailable
			} else {
				imgName = NSImageNameStatusNone
			}
			return NSImage(imageLiteralResourceName: imgName)
		}
	}
	
}



class MenuItemView: NSView {
	// This subclass is only needed to detect menu items with custom views
}
