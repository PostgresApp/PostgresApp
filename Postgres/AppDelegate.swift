//
//  AppDelegate.swift
//  Postgres
//
//  Created by Chris on 22/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa
import ServiceManagement
import Sparkle

class AppDelegate: NSObject, NSApplicationDelegate, SUUpdaterDelegate {
	
	let serverManager: ServerManager = ServerManager.shared
	var hideMenuHelperApp = UserDefaults.standard.bool(forKey: "HideMenuHelperApp")
	
	
	func applicationWillFinishLaunching(_ notification: Notification) {
	}
	
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		NotificationCenter.default.addObserver(forName: Server.PropertyChangedNotification, object: nil, queue: OperationQueue.main) { _ in
			self.serverManager.saveServers()
		}
		
		DistributedNotificationCenter.default.addObserver(forName: Server.StatusChangedNotification, object: nil, queue: OperationQueue.main) { _ in
			self.serverManager.refreshServerStatuses()
		}
		
		NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: OperationQueue.main) { _ in
			let hideMenuHelperApp = UserDefaults.standard.bool(forKey: "HideMenuHelperApp")
			if self.hideMenuHelperApp != hideMenuHelperApp {
				self.hideMenuHelperApp = hideMenuHelperApp
				
				if self.hideMenuHelperApp {
					let runningMenuHelperApps = NSRunningApplication.runningApplications(withBundleIdentifier: "com.postgresapp.PostgresMenuHelper")
					for app in runningMenuHelperApps where app.bundleURL!.path == Bundle.main.url(forAuxiliaryExecutable: "PostgresMenuHelper.app")!.path {
						app.terminate()
					}
				} else {
					let url = Bundle.main.url(forAuxiliaryExecutable: "PostgresMenuHelper.app")!
					NSWorkspace.shared().open(url)
				}
			}
		}
		
		
		if Bundle.main.bundlePath == "/Applications/Postgres.app" {
			enableLoginHelperApp(true)
		} else {
			let hideMenuHelperApp = UserDefaults.standard.bool(forKey: "HideMenuHelperApp")
			print("hideMenuHelperApp=\(hideMenuHelperApp)")
			if !hideMenuHelperApp {
				let url = Bundle.main.url(forAuxiliaryExecutable: "PostgresMenuHelper.app")!
				NSWorkspace.shared().open(url)
				NSApp.activate(ignoringOtherApps: true)
			}
		}
	}
	
	
	func applicationDidBecomeActive(_ notification: Notification) {
		serverManager.refreshServerStatuses()
	}
	
	
	@IBAction func openHelp(_ sender: AnyObject?) {
		NSWorkspace.shared().open(URL(string: "http://postgresapp.com/documentation/")!)
	}
	
	
	private func enableLoginHelperApp(_ enabled: Bool) {
		let helperAppURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Library/LoginItems/PostgresLoginHelper.app")
		if LSRegisterURL(helperAppURL as CFURL, true) != noErr {
			print("Failed to register PostgresLoginHelper URL")
		}
		if SMLoginItemSetEnabled("com.postgresapp.PostgresLoginHelper" as CFString, enabled) == false {
			print("Failed to enable PostgresLoginHelper as login item")
		}
	}
	
	
	
	// SUUpdater delegate methods
	func updater(_ updater: SUUpdater!, willInstallUpdate item: SUAppcastItem!) {
		print("updaterWillInstallUpdate")
		
		for server in serverManager.servers where server.running {
			_ = server.stopSync()
		}
	}
	
}

