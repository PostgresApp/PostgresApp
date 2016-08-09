//
//  SplitView.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {
	
	@IBOutlet var sideBarItem: NSSplitViewItem!
	@IBOutlet var mainViewItem: NSSplitViewItem!
	
	
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
		self.invalidateRestorableState()
	}
	
	
	override func encodeRestorableState(with coder: NSCoder) {
		coder.encode(splitViewItems.contains(sideBarItem), forKey: "sideBarVisible")
		super.encodeRestorableState(with: coder)
	}
	
	override func restoreState(with coder: NSCoder) {
		let sideBarVisible = coder.decodeBool(forKey: "sideBarVisible")
		if splitViewItems.contains(sideBarItem) {
			if !sideBarVisible {
				removeSplitViewItem(sideBarItem)
				(self.mainViewItem.viewController as? MainViewController)?.toggleSidebarButton.image = NSImage(imageLiteralResourceName: NSImageNameRightFacingTriangleTemplate)
				
			}
		} else {
			if sideBarVisible {
				addSplitViewItem(sideBarItem)
				(self.mainViewItem.viewController as? MainViewController)?.toggleSidebarButton.image = NSImage(imageLiteralResourceName: NSImageNameLeftFacingTriangleTemplate)
			}
		}
		super.restoreState(with: coder)
	}
	
}
