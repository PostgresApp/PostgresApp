//
//  AppDelegate.swift
//  Postgres
//
//  Created by Chris on 22/06/16.
//  This code is released under the terms of the PostgreSQL License.
//

import Cocoa
import Sparkle
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate, SUUpdaterDelegate, NSAlertDelegate, NSMenuDelegate {
	
	let serverManager: ServerManager = ServerManager.shared
	
	let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
	let statusIcon = NSImage(named: "statusicon")!

	@IBOutlet var sparkleUpdater: SUUpdater!
	@IBOutlet var preferencesMenuItem: NSMenuItem!
	@IBOutlet var mainWindowMenuItem: NSMenuItem!
		
	func isFirstLaunch() -> Bool {
		if UserDefaults.standard.bool(forKey: "alreadyLaunched") == false {
			UserDefaults.standard.set(true, forKey: "alreadyLaunched")
			return true
		}
		return false
	}
		
	func applicationDidFinishLaunching(_ notification: Notification) {
		let launchedAsLoginItem = NSAppleEventManager.shared().currentAppleEvent?.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue == keyAELaunchedAsLogInItem
		if !launchedAsLoginItem {
			showMainWindow()
			CrashLogCollector.shared.scanInBackground()
		}
		let clientAppPath = UserDefaults.standard.string(forKey: "PreferredClientApplicationPath") ?? ""
		if clientAppPath.isEmpty {
			// Read the old setting, reverting to Terminal as default
			let preferredClientAppName = UserDefaults.standard.string(forKey: "ClientAppName") ?? "Terminal"
			let newClientAppURL: URL?
			switch preferredClientAppName {
			case "Postico":
				newClientAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "at.eggerapps.Postico.2.MacAppStore") ?? NSWorkspace.shared.urlForApplication(withBundleIdentifier: "at.eggerapps.Postico") 
			case "iTerm":
				newClientAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.googlecode.iterm2")
			case "Terminal":
				newClientAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal")
			default:
				newClientAppURL = nil
			}
			if let newClientAppURL {
				UserDefaults.standard.set(newClientAppURL.path, forKey: "PreferredClientApplicationPath")
			}
		}
		
		ServerManager.shared.loadServers()
		if isFirstLaunch() {
			ServerManager.shared.checkForExistingDataDirectories()
		}
		ServerManager.shared.createDefaultServer()
		ServerManager.shared.refreshServerStatuses()
	
		NotificationCenter.default.addObserver(forName: Server.PropertyChangedNotification, object: nil, queue: OperationQueue.main) { _ in
			self.serverManager.saveServers()
		}
		
		DistributedNotificationCenter.default.addObserver(forName: Server.StatusChangedNotification, object: nil, queue: OperationQueue.main) { _ in
			self.serverManager.refreshServerStatuses()
		}
				
		LaunchAtLoginManager.shared.configureLoginItem()
		
		for server in serverManager.servers where server.startOnLogin && server.serverStatus == .Startable {
			server.start { _ in }
		}
		
		statusMenu.addItem(withTitle: "Open Postgres", action: #selector(showMainWindow), keyEquivalent: "")
		statusMenu.addItem(withTitle: "Settings…", action: #selector(showPreferences), keyEquivalent: "")
		statusMenu.addItem(withTitle: "Check for Updates…", action: #selector(checkForUpdates), keyEquivalent: "")
		statusMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "")
		statusMenu.addItem(.separator())
		statusMenu.delegate = self
		
		statusItem.button!.image = statusIcon
		statusItem.behavior = .removalAllowed // if we don't allow this, macOS Tahoe will disable the icon in system settings if the user drags the icon from the status bar
		statusItem.isVisible = !UserDefaults.standard.bool(forKey: "HideMenuHelperApp")
		UserDefaults.standard.addObserver(self, forKeyPath: "HideMenuHelperApp", context: nil)
		statusItem.addObserver(self, forKeyPath: "isVisible", context: nil)
		statusItem.menu = statusMenu
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if let object = object as? AnyObject {
			if object === statusItem  && keyPath == "isVisible" {
				// detect when the user hides icon by dragging away from menu bar
				let hideMenuItem = !statusItem.isVisible
				if UserDefaults.standard.bool(forKey: "HideMenuHelperApp") != hideMenuItem {
					UserDefaults.standard.set(hideMenuItem, forKey: "HideMenuHelperApp")
				}
				return
			}
			if object is UserDefaults && keyPath == "HideMenuHelperApp" {
				// detect when the user hides icon by changing user defaults
				let statusItemIsVisible = !UserDefaults.standard.bool(forKey: "HideMenuHelperApp")
				if statusItem.isVisible != statusItemIsVisible {
					statusItem.isVisible = statusItemIsVisible
				}
				return
			}
		}
		super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
	}
	
	let statusMenu = NSMenu()
	var menuItemViewControllers: [MenuItemViewController] = []

	func menuNeedsUpdate(_ menu: NSMenu) {
		guard menu == statusMenu else { return }
		
		serverManager.refreshServerStatuses()
		
		menuItemViewControllers.removeAll()
		
		for item in statusMenu.items where item.view is MenuItemView {
			statusMenu.removeItem(item)
		}
		
		var maxStringWidth = CGFloat(0)
		for server in serverManager.servers {
			let stringWidth = (server.name as NSString).size(withAttributes: [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12)]).width
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

	var hasVisibleWindowsThatCanBecomeKey: Bool {
		return NSApp.windows.contains { $0.isVisible && $0.canBecomeKey }
	}

	func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
		showMainWindow()
		return false
	}

	func applicationDidBecomeActive(_ notification: Notification) {
		DispatchQueue.main.async {
			self.serverManager.refreshServerStatuses()
		}
	}
	
	func applicationWillTerminate(_ notification: Notification) {
		for server in serverManager.servers where server.running {
			try? server.stopSync()
		}
	}
	
	@IBAction func quitWithConfirmation(_ sender: AnyObject?) {
		let alert = NSAlert()
		alert.messageText = "Do you want to completely quit Postgres.app?"
		alert.informativeText = "This will stop servers and hide the menu bar icon.\n\nIf you want to continue using PostgreSQL servers, Postgres.app can continue running in the background instead."
		alert.addButton(withTitle: "Quit")
		alert.addButton(withTitle: "Continue in background")
		alert.addButton(withTitle: "Cancel")
		switch alert.runModal() {
		case .alertFirstButtonReturn:
			NSApp.terminate(nil)
		case .alertSecondButtonReturn:
			for window in NSApp.windows where window.isVisible && window.canBecomeKey {
				window.performClose(nil)
			}
		default:
			break
		}
	}
		
	@IBAction func showMainWindow(_ sender: Any? = nil) {
		if #available(macOS 14.0, *) {
			// this seems to help with getting the app to activate
			// i have no idea how the window server decides to allow postgres.app to activate
			NSApp.yieldActivation(toApplicationWithBundleIdentifier: Bundle.main.bundleIdentifier!)
		}
		NSApp.activate(ignoringOtherApps: true)
		// This is a workaround to trigger a storyboard segue programmatically
		// If you come up with a better solution please let me know :)
		NSApp.sendAction(mainWindowMenuItem.action!, to: mainWindowMenuItem.target, from: mainWindowMenuItem)
}
	
	@IBAction func showPreferences(_ sender: Any? = nil) {
		if #available(macOS 14.0, *) {
			// this seems to help with getting the app to activate
			// i have no idea how the window server decides to allow postgres.app to activate
			NSApp.yieldActivation(toApplicationWithBundleIdentifier: Bundle.main.bundleIdentifier!)
		}
		NSApp.activate(ignoringOtherApps: true)
		// The preference window is displayed by a storyboard segue hooked up to a menu item
		// This seems to be the easiest way to trigger that segue programmatically
		NSApp.sendAction(preferencesMenuItem.action!, to: preferencesMenuItem.target, from: preferencesMenuItem)
	}
	
	@IBAction func checkForUpdates(_ sender: Any? = nil) {
		if #available(macOS 14.0, *) {
			// this seems to help with getting the app to activate
			// i have no idea how the window server decides to allow postgres.app to activate
			NSApp.yieldActivation(toApplicationWithBundleIdentifier: Bundle.main.bundleIdentifier!)
		}
		NSApp.activate(ignoringOtherApps: true)
		sparkleUpdater.checkForUpdates(sender)
	}
	
	@IBAction func openHelp(_ sender: AnyObject?) {
		NSWorkspace.shared.open(URL(string: "https://postgresapp.com/l/help/")!)
	}
	
	// SUUpdater delegate methods
	func updater(_ updater: SUUpdater, willInstallUpdate item: SUAppcastItem) {
		for server in serverManager.servers where server.running {
			try? server.stopSync()
		}
		for menuApp in NSRunningApplication.runningApplications(withBundleIdentifier: "com.postgresapp.Postgres2MenuHelper") {
			menuApp.terminate()
		}
	}
}
