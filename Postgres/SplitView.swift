//
//  SplitView.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController, MainWindowModelConsumer {
	
	dynamic var mainWindowModel: MainWindowModel! {
		didSet {
			self.sidebarItem.isCollapsed = !mainWindowModel.sidebarVisible
			self.modelSidebarObserver = mainWindowModel.observe("sidebarVisible") { [weak self] _ in
				guard let this = self else { return }
				if !this.ignoreSidebarVisibleChange {
					if this.mainWindowModel.sidebarVisible == this.sidebarItem.isCollapsed {
						this.toggleSidebar(nil)
					}
				}
			}
		}
	}
	
	var modelSidebarObserver: KeyValueObserver?
	var ignoreSidebarVisibleChange = false
	
	@IBOutlet var sidebarItem: NSSplitViewItem!
	
	
	override func splitViewDidResizeSubviews(_ notification: Notification) {
		super.splitViewDidResizeSubviews(notification)
		guard let model = mainWindowModel else { return }
		ignoreSidebarVisibleChange = true
		model.sidebarVisible = !sidebarItem.isCollapsed
		ignoreSidebarVisibleChange = false
	}
	
	
	
}
