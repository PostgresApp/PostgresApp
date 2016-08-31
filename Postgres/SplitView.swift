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
	
	@IBOutlet var serverViewItem: NSSplitViewItem!
	@IBOutlet var sideBarItem: NSSplitViewItem!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		modelObserver = self.observe("mainWindowModel.sidebarVisible") { [weak self] _ in
			guard let this = self where this.mainWindowModel != nil else { return }
			this.updateServerListView()
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
