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
	
	let serverManager = ServerManager.shared
	
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
	
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		templateOffImage = NSImage(named: "statusicon-off")
		templateOnImage = NSImage(named: "statusicon-on")
		templateOffImage.isTemplate = isDarkMode
		templateOnImage.isTemplate = isDarkMode
		
		DistributedNotificationCenter.default().addObserver(forName: InterfaceThemeChangedNotification, object: nil, queue: OperationQueue.main()) { _ in
			self.templateOffImage.isTemplate = self.isDarkMode
			self.templateOnImage.isTemplate = self.isDarkMode
		}
		
		DistributedNotificationCenter.default().addObserver(forName: HideStatusMenuChangedNotification, object: nil, queue: OperationQueue.main()) { _ in
			self.updateStatusItem()
		}
		
		updateStatusItem()
		
		serverManager.loadServers()
		serverManager.startServers()
	}
	
	
	private func updateStatusItem() {
		guard let hideStatusMenu = UserDefaults.shared()?.bool(forKey: "HideStatusMenu") else { return }
		if hideStatusMenu {
			statusItem = nil
		} else {
			statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
			statusItem.highlightMode = true
			statusItem.menu = statusMenu
			statusItem.image = templateOffImage
			statusItem.alternateImage = templateOnImage
		}
	}
	
	
	func menuNeedsUpdate(_ menu: NSMenu) {
		guard menu == statusMenu else { return }
		
		serverManager.loadServers()
		serverManager.refreshServerStatuses()
		
		for item in statusMenu.items where item.view is MenuItemView {
			statusMenu.removeItem(item)
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
		let postgresAppURL = try! Bundle.main().bundleURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
		if !NSWorkspace.shared().launchApplication(postgresAppURL.path!) {
			let alert = NSAlert()
			alert.messageText = "Could not launch Postgres.app"
			alert.runModal()
		}
	}
	
	
}

