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
		
		modelObserver = self.observe("mainWindowModel.sidebarVisible", options: .initial) { [weak self] _ in
			print("SplitViewController: model changed")
			guard self?.mainWindowModel != nil else { return }
			self?.updateServerListView()
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
