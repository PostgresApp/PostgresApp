//
//  SplitView.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController, MainWindowModelConsumer {
	@IBOutlet var sidebarItem: NSSplitViewItem!
	
	var ignoreSidebarVisibleChange = false
	var modelSidebarObserver: KeyValueObserver?
	
	dynamic var mainWindowModel: MainWindowModel! {
		willSet {
			if let modelSidebarObserver = modelSidebarObserver {
				mainWindowModel.removeObserver(modelSidebarObserver, forKeyPath: modelSidebarObserver.keyPath)
			}
		}
		didSet {
			self.sidebarItem.isCollapsed = !mainWindowModel.sidebarVisible
			self.modelSidebarObserver = mainWindowModel.observe("sidebarVisible") { [weak self] _ in
				guard let this = self else { return }
				if !this.ignoreSidebarVisibleChange {
					if this.mainWindowModel.sidebarVisible == this.sidebarItem.isCollapsed {
						if #available(OSX 10.11, *) {
							this.toggleSidebar(nil)
						} else {
							this.sidebarItem.isCollapsed = !this.sidebarItem.isCollapsed
						}
					}
				}
			}
		}
	}
	
	deinit {
		if let modelSidebarObserver = modelSidebarObserver {
			mainWindowModel.removeObserver(modelSidebarObserver, forKeyPath: modelSidebarObserver.keyPath)
		}
	}
	
	
	override func splitViewDidResizeSubviews(_ notification: Notification) {
		if NSSplitViewController.instancesRespond(to: #selector(NSSplitViewController.splitViewDidResizeSubviews(_:))) {
			super.splitViewDidResizeSubviews(notification)
		}
		guard let model = mainWindowModel else { return }
		ignoreSidebarVisibleChange = true
		model.sidebarVisible = !sidebarItem.isCollapsed
		ignoreSidebarVisibleChange = false
	}
	
}
