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
	
	let serverManager = ServerManager.shared
	
	let InterfaceStyle = "AppleInterfaceStyle"
	let InterfaceStyleDark = "Dark"
	let InterfaceThemeChangedNotification = "AppleInterfaceThemeChangedNotification" as NSNotification.Name
	
	var statusItem: NSStatusItem?
	var templateOffImage = NSImage(named: "statusicon-off")!
	var templateOnImage = NSImage(named: "statusicon-on")!
	var isDarkMode: Bool {
		return (UserDefaults.standard().object(forKey: InterfaceStyle) as? String) == InterfaceStyleDark
	}
	
	@IBOutlet var statusMenu: NSMenu!
	
	
	func applicationWillFinishLaunching(_ notification: Notification) {
		serverManager.loadServers()
		serverManager.startServers()
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		DistributedNotificationCenter.default().addObserver(forName: InterfaceThemeChangedNotification, object: nil, queue: OperationQueue.main()) { _ in
			self.updateStatusItem()
		}
		
		DistributedNotificationCenter.default().addObserver(forName: HideStatusMenuChangedNotification, object: nil, queue: OperationQueue.main()) { _ in
			self.updateStatusItem()
		}
		
		updateStatusItem()
	}
	
	
	private func updateStatusItem() {
		guard let hideStatusMenu = UserDefaults.shared()?.bool(forKey: "HideStatusMenu") else { return }
		if hideStatusMenu {
			statusItem = nil
		} else {
			if statusItem == nil {
				statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
				statusItem!.highlightMode = true
				statusItem!.menu = statusMenu
			}
			templateOffImage.isTemplate = isDarkMode
			templateOnImage.isTemplate = isDarkMode
			statusItem!.image = templateOffImage
			statusItem!.alternateImage = templateOnImage
		}
	}
	
	
	func menuNeedsUpdate(_ menu: NSMenu) {
		guard menu == statusMenu else { return }
		
		serverManager.loadServers()
		serverManager.refreshServerStatuses()
		
		for item in statusMenu.items where item.view is MenuItemView {
			statusMenu.removeItem(item)
		}
		
		
		var maxStringWidth: CGFloat = 0
		for server in serverManager.servers {
			let stringWidth = (server.name as NSString).size(withAttributes: [NSFontAttributeName: NSFont.systemFont(ofSize: 12)]).width
			maxStringWidth = max(stringWidth, maxStringWidth)
		}
		
		for server in serverManager.servers {
			guard let menuItemViewController = MenuItemViewController(server) else { return }
			
			let menuItem = NSMenuItem()
			
			menuItemViewController.view.setFrameSize(NSSize(width: min(max(150+maxStringWidth, 200), 300), height: 32))
			menuItem.view = menuItemViewController.view
			
			statusMenu.addItem(menuItem)
		}
	}
	
	
	@IBAction func openPostgresApp(_ sender: AnyObject?) {
		let postgresAppURL = try! Bundle.main().bundleURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
		if !NSWorkspace.shared().launchApplication(postgresAppURL.path!) {
			let alert = NSAlert()
			alert.messageText = "Could not launch Postgres.app"
			alert.runModal()
		}
	}
	
}

