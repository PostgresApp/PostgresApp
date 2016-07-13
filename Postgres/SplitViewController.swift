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
		if splitViewItems.contains(sideBarItem) {
			removeSplitViewItem(sideBarItem)
			var frm = self.view.window!.frame
			frm.size.width -= sideBarItem.viewController.view.frame.size.width + self.splitView.dividerThickness
			view.window?.setFrame(frm, display: false)
			sender.image = NSImage(imageLiteralResourceName: NSImageNameRightFacingTriangleTemplate)
		} else {
			addSplitViewItem(sideBarItem)
			var frm = self.view.window!.frame
			frm.size.width += sideBarItem.viewController.view.frame.size.width + self.splitView.dividerThickness
			view.window?.setFrame(frm, display: false)
			sender.image = NSImage(imageLiteralResourceName: NSImageNameLeftFacingTriangleTemplate)
		}
	}
	
}
