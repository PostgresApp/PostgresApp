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
	@IBOutlet var sideBarItem: NSSplitViewItem!
	@IBOutlet var mainViewItem: NSSplitViewItem!
	
	
	override func awakeFromNib() {
		self.addObserver(self, forKeyPath: "mainWindowModel.sidebarVisible", options: [.new], context: nil)
	}
	
	deinit {
		self.removeObserver(self, forKeyPath: "mainWindowModel.sidebarVisible", context: nil)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
		switch keyPath {
		case .some("mainWindowModel.sidebarVisible"):
			updateServerListView()
		default:
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
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
