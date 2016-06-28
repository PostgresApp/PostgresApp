//
//  SplitViewController.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {
	
	@IBOutlet var sideBarItem: NSSplitViewItem!
	
	
	@IBAction func toggleServerListView(_ sender: NSButton) {
		if self.splitViewItems.contains(sideBarItem) {
			self.removeSplitViewItem(sideBarItem)
			var frame = NSApp.mainWindow!.frame
			frame.size.width -= sideBarItem.viewController.view.frame.size.width + self.splitView.dividerThickness
			NSApp.mainWindow?.setFrame(frame, display: false)
			sender.image = NSImage.init(imageLiteralResourceName: NSImageNameRightFacingTriangleTemplate)
		}
		else {
			self.addSplitViewItem(sideBarItem)
			var frame = NSApp.mainWindow!.frame
			frame.size.width += sideBarItem.viewController.view.frame.size.width + self.splitView.dividerThickness
			NSApp.mainWindow?.setFrame(frame, display: false)
			sender.image = NSImage.init(imageLiteralResourceName: NSImageNameLeftFacingTriangleTemplate)
		}
	}
	
	
}
