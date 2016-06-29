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
			var frame = self.view.window!.frame
			frame.size.width -= sideBarItem.viewController.view.frame.size.width + self.splitView.dividerThickness
			self.view.window?.setFrame(frame, display: false, animate: true)
			sender.image = NSImage.init(imageLiteralResourceName: NSImageNameRightFacingTriangleTemplate)
		}
		else {
			self.addSplitViewItem(sideBarItem)
			var frame = self.view.window!.frame
			frame.size.width += sideBarItem.viewController.view.frame.size.width + self.splitView.dividerThickness
			self.view.window?.setFrame(frame, display: false, animate: true)
			sender.image = NSImage.init(imageLiteralResourceName: NSImageNameLeftFacingTriangleTemplate)
		}
	}
	
	
}
