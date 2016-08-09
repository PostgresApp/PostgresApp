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
	
	let serverManager = ServerManager.shared
	
	var statusItem: NSStatusItem!
	var templateOffImage: NSImage!
	var templateOnImage: NSImage!
	var isDarkMode: Bool {
		return (UserDefaults.standard().object(forKey: InterfaceStyle) as? String) == InterfaceStyleDark
	}
	
	@IBOutlet weak var statusMenu: NSMenu!
	
	
	func applicationWillFinishLaunching(_ notification: Notification) {
		validatePostgresApp()
	}
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		templateOffImage = NSImage(named: "statusicon-off")
		templateOnImage = NSImage(named: "statusicon-on")
		templateOffImage.isTemplate = isDarkMode
		templateOnImage.isTemplate = isDarkMode
		
		statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
		statusItem.highlightMode = true
		statusItem.menu = statusMenu
		statusItem.image = templateOffImage
		statusItem.alternateImage = templateOnImage
		
		DistributedNotificationCenter.default().addObserver(forName: InterfaceThemeChangedNotification, object: nil, queue: OperationQueue.main()) { (notification) in
			self.templateOffImage.isTemplate = self.isDarkMode
			self.templateOnImage.isTemplate = self.isDarkMode
		}
		
		serverManager.loadServersForHelperApp()
		serverManager.refreshServerStatuses()
	}
	
	
	func menuNeedsUpdate(_ menu: NSMenu) {
		guard menu == statusMenu else { return }
		
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
		validatePostgresApp()
		NSWorkspace.shared().launchApplication(AppDelegate.PG_APP_PATH)
	}
	
	
	private func validatePostgresApp() {
		if !FileManager.default().fileExists(atPath: AppDelegate.PG_APP_PATH) {
			let alert = NSAlert()
			alert.messageText = "Postgres.app not found"
			alert.informativeText = "Make sure Postgres.app is inside your Applications folder."
			alert.addButton(withTitle: "OK")
			alert.runModal()
			exit(1)
		}
	}
	
	
}

