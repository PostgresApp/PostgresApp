//
//  SplitView.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController, MainWindowModelConsumer {
	
	dynamic var mainWindowModel: MainWindowModel!
	var modelObserver: KeyValueObserver!
	
	@IBOutlet var sideBarItem: NSSplitViewItem!
	@IBOutlet var mainViewItem: NSSplitViewItem!
	
	
	override func awakeFromNib() {
		modelObserver = KeyValueObserver.observe(mainWindowModel, keyPath: "sidebarVisible", options: .new) {
			print("SplitViewController: model changed")
			self.updateServerListView()
		}
	}
	
	
	private func updateServerListView() {
		if mainWindowModel.sidebarVisible && !splitViewItems.contains(sideBarItem) {
			self.addSplitViewItem(sideBarItem)
			(sideBarItem.viewController as! SidebarController).mainWindowModel = self.mainWindowModel
		} else if !mainWindowModel.sidebarVisible && splitViewItems.contains(sideBarItem) {
			self.removeSplitViewItem(sideBarItem)
		}
	}
	
}
