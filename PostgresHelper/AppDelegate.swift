//
//  AppDelegate.swift
//  PostgresMenuHelper
//
//  Created by Chris on 05/09/2016.
//  This code is released under the terms of the PostgreSQL License.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
	
	let serverManager = ServerManager.shared
	
	let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
	let statusIcon = NSImage(named: "statusicon")!
	
	var menuItemViewControllers: [MenuItemViewController] = []
	
	var mainApp: SBApplication {
		let mainAppURL = Bundle.mainApp!.bundleURL
		let mainApp = SBApplication(url: mainAppURL)!
		return mainApp
	}
	
	@IBOutlet var statusMenu: NSMenu!
	
    func applicationWillFinishLaunching(_ notification: Notification) {
        if let myBundleVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String {
            for app in NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier!) {
                if app.bundleURL == Bundle.main.bundleURL {
                    continue
                }
                guard let bundleURL = app.bundleURL,
                      let bundle = Bundle(url: bundleURL),
                      let bundleVersion = bundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
                else {
                    print("Detected broken menu helper. Trying to quit it.")
                    app.terminate()
                    continue
                }
                
                switch myBundleVersion.compare(bundleVersion, options: .numeric) {
                case .orderedAscending:
                    // other app is newer
                    print("Detected newer menu helper is already running. Quitting.")
                    exit(1)
                case .orderedDescending:
                    print("Detected older menu helper. Trying to quit it.")
                    app.terminate()
                case .orderedSame:
                    print("Detected identical menu helper. Trying to quit it.")
                    app.terminate()
                }
            }
        }
    }
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		statusItem.menu = statusMenu
		statusItem.button!.image = statusIcon
		
		// Start PostgreSQL servers
		// This may take a few seconds
		let serverManager = ServerManager.shared
		serverManager.loadServers()
		for server in serverManager.servers {
			if server.startOnLogin {
				DispatchQueue.global().async {
					do {
						try server.startSync()
					}
					catch let error as NSError {
						Swift.print("Failed to start server \(server.name): \(error.localizedDescription)")
					}
				}
			}
		}
	}
	
	func applicationWillTerminate(_ notification: Notification) {
		// stop all servers
		// This may take a few seconds
		let serverManager = ServerManager.shared
		serverManager.loadServers()
		for server in serverManager.servers {
			do {
				try server.stopSync()
			}
			catch let error as NSError {
				Swift.print("Failed to stop server \(server.name): \(error.localizedDescription)")
			}
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
	
	
	@IBAction func openPostgresApp(_ sender: AnyObject?) {
		if #available(macOS 14.0, *) {
			NSApp.yieldActivation(toApplicationWithBundleIdentifier: Bundle.mainApp!.bundleIdentifier!)
		}
		mainApp.activate()
	}
	
	@IBAction func openPreferences(_ sender: AnyObject?) {
		if #available(macOS 14.0, *) {
			NSApp.yieldActivation(toApplicationWithBundleIdentifier: Bundle.mainApp!.bundleIdentifier!)
		}
		mainApp.openPreferences()
	}
	
	@IBAction func checkForUpdates(_ sender: AnyObject?) {
		if #available(macOS 14.0, *) {
			NSApp.yieldActivation(toApplicationWithBundleIdentifier: Bundle.mainApp!.bundleIdentifier!)
		}
		mainApp.checkForUpdates()
	}
	
	@IBAction func quitPostgresMenuHelper(_ sender: AnyObject?) {
		for server in serverManager.servers where server.running {
			try? server.stopSync()
		}
		
		for app in NSRunningApplication.runningApplications(withBundleIdentifier: "com.postgresapp.Postgres2") {
			app.terminate()
		}
		
		NSApp.terminate(nil)
	}
	
}
