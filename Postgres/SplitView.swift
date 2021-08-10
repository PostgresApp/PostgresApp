//
//  SplitView.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {
	@IBOutlet var sidebarItem: NSSplitViewItem!
	
	var ignoreSidebarVisibleChange = false
	var userDefaultObserver: KeyValueObserver?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		sidebarItem.isCollapsed = !UserDefaults.standard.bool(forKey: "SidebarVisible")
		userDefaultObserver = UserDefaults.standard.observe("SidebarVisible") { [weak self] _ in
			guard let this = self else { return }
			if !this.ignoreSidebarVisibleChange {
				if UserDefaults.standard.bool(forKey: "SidebarVisible") == this.sidebarItem.isCollapsed {
					if #available(OSX 10.11, *) {
						this.toggleSidebar(nil)
					} else {
						this.sidebarItem.isCollapsed = !this.sidebarItem.isCollapsed
					}
				}
			}
		}
	}
	
	deinit {
		if let userDefaultObserver = userDefaultObserver {
			UserDefaults.standard.removeObserver(userDefaultObserver, forKeyPath: userDefaultObserver.keyPath)
		}
	}
	
	override func splitViewDidResizeSubviews(_ notification: Notification) {
		if NSSplitViewController.instancesRespond(to: #selector(NSSplitViewController.splitViewDidResizeSubviews(_:))) {
			super.splitViewDidResizeSubviews(notification)
		}
		if notification.userInfo?["NSSplitViewUserResizeKey"] as? Bool == true {
			ignoreSidebarVisibleChange = true
			UserDefaults.standard.setValue(!sidebarItem.isCollapsed, forKey: "SidebarVisible")
			ignoreSidebarVisibleChange = false
		}
	}
	
}
