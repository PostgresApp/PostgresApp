//
//  SplitViewController.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {
	
	@IBAction func toggleServerListView(_ sender: NSButton) {
		let serverListView = self.splitViewItems[0].viewController.view
		
		if serverListView.superview != nil || self.splitView.isSubviewCollapsed(serverListView) {
			serverListView.isHidden = false
			self.splitView.addSubview(serverListView)
			sender.image = NSImage.init(imageLiteralResourceName: NSImageNameLeftFacingTriangleTemplate)
			var oldFrame = NSApp.mainWindow?.frame
			oldFrame?.size.width += serverListView.frame.size.width+1
			NSApp.mainWindow?.setFrame(oldFrame!, display: false)
		}
		else {
			serverListView.removeFromSuperview()
			sender.image = NSImage.init(imageLiteralResourceName: NSImageNameRightFacingTriangleTemplate)
			var oldFrame = NSApp.mainWindow?.frame
			oldFrame?.size.width -= serverListView.frame.size.width+1
			NSApp.mainWindow?.setFrame(oldFrame!, display: false)
		}
		
	}
	
}
