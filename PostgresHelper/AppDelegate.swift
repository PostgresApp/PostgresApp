//
//  AppDelegate.swift
//  PostgresHelper
//
//  Created by Chris on 22/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	//let serverManager = ServerManager.shared
	
	let InterfaceStyle = "AppleInterfaceStyle"
	let InterfaceStyleDark = "Dark"
	let InterfaceThemeChangedNotification = "AppleInterfaceThemeChangedNotification" as NSNotification.Name
	
	@IBOutlet weak var statusMenu: NSMenu!
	
	var statusItem: NSStatusItem!
	var templateOffImage: NSImage!
	var templateOnImage: NSImage!
	var isDarkMode: Bool {
		return (UserDefaults.standard().object(forKey: InterfaceStyle) as? String) == InterfaceStyleDark
	}
	
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
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
		
		openPostgresApp(nil)
	}
	
	
	@IBAction func openPostgresApp(_ sender: AnyObject?) {
		if !NSWorkspace.shared().launchApplication("/Applicationss/Postgres.app") {
			let alert = NSAlert()
			alert.messageText = "Could not launch Postgres.app"
			alert.informativeText = "Make sure Postgres.app is inside your Applications folder."
			alert.alertStyle = .critical
			alert.runModal()
		}
	}
	
	
}

