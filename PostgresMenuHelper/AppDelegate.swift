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
	let statusIcon = NSImage(named: "statusicon")!
	
	var menuItemViewControllers: [MenuItemViewController] = []
	
	lazy var mainApp: SBApplication = {
		let mainAppURL = Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
		let mainApp = SBApplication(url: mainAppURL)!
		return mainApp
	}()
	
	@IBOutlet var statusMenu: NSMenu!
	
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		statusItem.menu = statusMenu
		statusItem.image = statusIcon
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
		if checkAppleEventPermissions() {
			mainApp.activate()
		}
	}
	
	@IBAction func openPreferences(_ sender: AnyObject?) {
		if checkAppleEventPermissions() {
			mainApp.activate()
			mainApp.openPreferences()
		}
	}
	
	@IBAction func checkForUpdates(_ sender: AnyObject?) {
		if checkAppleEventPermissions() {
			mainApp.activate()
			mainApp.checkForUpdates()
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
	
	
	private func checkAppleEventPermissions() -> Bool {
		guard #available(OSX 10.14, *) else { return true }
		
		let target = NSAppleEventDescriptor(bundleIdentifier: "com.postgresapp.Postgres2")
		let status = AEDeterminePermissionToAutomateTarget(target.aeDesc, typeWildCard, typeWildCard, true)
		
		if status == errAEEventNotPermitted {
			let alert = NSAlert()
			alert.messageText = "PostgresMenuHelper has no permissions to control Postgres.app"
			alert.informativeText = "Please open System Preferences -> Security and Privacy -> Automation and allow Postgres.app to control other apps."
			alert.alertStyle = .warning
			alert.runModal()
			return false
		}
		
		return true
	}
}
