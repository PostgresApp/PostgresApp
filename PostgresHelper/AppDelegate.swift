//
//  AppDelegate.swift
//  PostgresHelper
//
//  Created by Chris on 22/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
	
	static var PG_APP_PATH: String {
		return "/Applications/Postgres.app"
	}
	
	let InterfaceStyle = "AppleInterfaceStyle"
	let InterfaceStyleDark = "Dark"
	let InterfaceThemeChangedNotification = "AppleInterfaceThemeChangedNotification" as NSNotification.Name
	
	var statusItem: NSStatusItem!
	var templateOffImage: NSImage!
	var templateOnImage: NSImage!
	var isDarkMode: Bool {
		return (UserDefaults.standard().object(forKey: InterfaceStyle) as? String) == InterfaceStyleDark
	}
	
	@IBOutlet weak var statusMenu: NSMenu!
	
	
	func applicationWillFinishLaunching(_ notification: Notification) {
		NSBeep()
	}
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		templateOffImage = NSImage(named: "statusicon-off")
		templateOnImage = NSImage(named: "statusicon-on")
		templateOffImage.isTemplate = isDarkMode
		templateOnImage.isTemplate = isDarkMode
		
		DistributedNotificationCenter.default().addObserver(forName: InterfaceThemeChangedNotification, object: nil, queue: OperationQueue.main()) { _ in
			self.templateOffImage.isTemplate = self.isDarkMode
			self.templateOnImage.isTemplate = self.isDarkMode
		}
		
		self.updateStatusItem()
		
		let serverManager = ServerManager()
		serverManager.loadServers()
		serverManager.startServers()
		
		DistributedNotificationCenter.default().addObserver(forName: StatusItemDidChangeNotificationName, object: nil, queue: OperationQueue.main()) { _ in
			self.updateStatusItem()
		}
	}
	
	
	private func updateStatusItem() {
		guard let showStatusItem = UserDefaults.mainDefaults()?.bool(forKey: "ShowStatusItem") else { return }
		if showStatusItem {
			self.statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
			self.statusItem.highlightMode = true
			self.statusItem.menu = statusMenu
			self.statusItem.image = templateOffImage
			self.statusItem.alternateImage = templateOnImage
		} else {
			self.statusItem = nil
		}
	}
	
	
	func menuNeedsUpdate(_ menu: NSMenu) {
		guard menu == statusMenu else { return }
		
		let serverManager = ServerManager()
		serverManager.loadServers()
		serverManager.refreshServerStatuses()
		
		for item in statusMenu.items {
			if let view = item.view where view.isKind(of: MenuItemView.self) {
				statusMenu.removeItem(item)
			}
		}
		
		for server in serverManager.servers {
			guard let menuItemViewController = MenuItemViewController(nibName: "MenuItemView", bundle: nil) else { return }
			menuItemViewController.server = server
			
			let menuItem = NSMenuItem()
			menuItem.view = menuItemViewController.view
			
			statusMenu.addItem(menuItem)
		}
	}
	
	
	@IBAction func openPostgresApp(_ sender: AnyObject?) {
		NSWorkspace.shared().launchApplication(AppDelegate.PG_APP_PATH)
	}
	
}

