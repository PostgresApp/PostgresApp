//
//  AppDelegate.swift
//  PostgresHelper
//
//  Created by Chris on 22/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Foundation
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	let kAppleInterfaceStyle = "AppleInterfaceStyle"
	let kAppleInterfaceStyleDark = "Dark"
	let kAppleInterfaceThemeChangedNotification = "AppleInterfaceThemeChangedNotification" as NSNotification.Name
	
	@IBOutlet weak var statusMenu: NSMenu!
	
	var statusItem: NSStatusItem!
	var templateOffImage: NSImage!
	var templateOnImage: NSImage!
	var isDarkMode: Bool {
		return (UserDefaults.standard().object(forKey: kAppleInterfaceStyle) as? String) == kAppleInterfaceStyleDark
	}
	
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		DistributedNotificationCenter.default().addObserver(forName: kAppleInterfaceThemeChangedNotification, object: nil, queue: OperationQueue.main()) { (notification) in
			self.templateOffImage.isTemplate = self.isDarkMode
			self.templateOnImage.isTemplate = self.isDarkMode
		}
		
		self.templateOffImage = NSImage(named: "status-off")
		self.templateOnImage = NSImage(named: "status-on")
		self.templateOffImage.isTemplate = self.isDarkMode
		self.templateOnImage.isTemplate = self.isDarkMode
		
		self.statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
		self.statusItem.highlightMode = true
		self.statusItem.menu = self.statusMenu
		self.statusItem.image = self.templateOffImage
		self.statusItem.alternateImage = self.templateOnImage
	}
	
	
	
	
}

