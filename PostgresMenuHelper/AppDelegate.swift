//
//  AppDelegate.swift
//  PostgresMenuHelper
//
//  Created by Chris on 05/09/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
	
	let serverManager = ServerManager.shared
	
	let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
	let templateOffImage = NSImage(named: "statusicon-off")!
	let templateOnImage = NSImage(named: "statusicon-on")!
	
	var isDarkMode: Bool {
		return UserDefaults.standard.object(forKey: "AppleInterfaceStyle") as? String == "Dark"
	}
	
	var menuItemViewControllers: [MenuItemViewController] = []
	
	@IBOutlet var statusMenu: NSMenu!
	
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		statusItem.highlightMode = true
		statusItem.menu = statusMenu
		statusItem.image = templateOffImage
		statusItem.alternateImage = templateOnImage
		templateOffImage.isTemplate = isDarkMode
		templateOnImage.isTemplate = isDarkMode
		
		DistributedNotificationCenter.default().addObserver(forName: Notification.Name("AppleInterfaceThemeChangedNotification"), object: nil, queue: OperationQueue.main) { _ in
			self.templateOffImage.isTemplate = self.isDarkMode
			self.templateOnImage.isTemplate = self.isDarkMode
		}
	}
	
	
	func menuNeedsUpdate(_ menu: NSMenu) {
		guard menu == statusMenu else { return }
		
		serverManager.loadServers()
		serverManager.refreshServerStatuses()
		
		menuItemViewControllers.removeAll()
		
		for item in statusMenu.items where item.view is MenuItemView {
			statusMenu.removeItem(item)
		}
		
		var maxStringWidth = CGFloat(0)
		for server in serverManager.servers {
			let stringWidth = (server.name as NSString).size(withAttributes: [NSFontAttributeName: NSFont.systemFont(ofSize: 12)]).width
			maxStringWidth = max(stringWidth, maxStringWidth)
		}
		
		for server in serverManager.servers {
			guard let menuItemViewController = MenuItemViewController(server) else { return }
			menuItemViewControllers.append(menuItemViewController)
			
			let menuItem = NSMenuItem()
			
			menuItemViewController.view.setFrameSize(NSSize(width: min(max(150+maxStringWidth, 200), 300), height: 32))
			menuItem.view = menuItemViewController.view
			
			statusMenu.addItem(menuItem)
		}
	}
	
	
	@IBAction func openPostgresApp(_ sender: AnyObject?) {
		let postgresAppPath = "/Applications/Postgres.app"
		if !NSWorkspace.shared().launchApplication(postgresAppPath) {
			let alert = NSAlert()
			alert.messageText = "Could not launch Postgres.app"
			alert.runModal()
		}
	}
	
	
	@IBAction func quitPostgresMenuHelper(_ sender: AnyObject?) {
		for server in serverManager.servers where server.running {
			_ = server.stopSync()
		}
		
		for app in NSRunningApplication.runningApplications(withBundleIdentifier: "com.postgresapp.Postgres2") {
			app.terminate()
		}
		
		NSApp.terminate(nil)
	}
	
}
