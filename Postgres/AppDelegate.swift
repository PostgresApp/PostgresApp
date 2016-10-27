//
//  AppDelegate.swift
//  Postgres
//
//  Created by Chris on 22/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa
import Sparkle

class AppDelegate: NSObject, NSApplicationDelegate, SUUpdaterDelegate {
	
	let serverManager: ServerManager = ServerManager.shared
	var hideMenuHelperApp = UserDefaults.standard.bool(forKey: "HideMenuHelperApp")
	
	
	func applicationWillFinishLaunching(_ notification: Notification) {
		UserDefaults.standard.registerPostgresDefaults()
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
					let runningMenuHelperApps = NSRunningApplication.runningApplications(withBundleIdentifier: "com.postgresapp.Postgres2MenuHelper")
					for app in runningMenuHelperApps where app.bundleURL!.path == Bundle.main.url(forAuxiliaryExecutable: "PostgresMenuHelper.app")!.path {
						app.terminate()
					}
				} else {
					let url = Bundle.main.url(forAuxiliaryExecutable: "PostgresMenuHelper.app")!
					NSWorkspace.shared().open(url)
				}
			}
		}
		
		createLaunchAgent()
		
		if UserDefaults.standard.bool(forKey: "HideMenuHelperApp") == false {
			let url = Bundle.main.url(forAuxiliaryExecutable: "PostgresMenuHelper.app")!
			NSWorkspace.shared().open(url)
			NSApp.activate(ignoringOtherApps: true)
		}
	}
	
	func applicationDidBecomeActive(_ notification: Notification) {
		serverManager.refreshServerStatuses()
	}
	
	
	@IBAction func openHelp(_ sender: AnyObject?) {
		NSWorkspace.shared().open(URL(string: "http://postgresapp.com/documentation/")!)
	}
	
	
	private func createLaunchAgent() {
		let laPath = NSHomeDirectory().appending("/Library/LaunchAgents")
		let laName = "com.postgresapp.Postgres2LoginHelper"
		if !FileManager.default.fileExists(atPath: laPath) {
			do {
				try FileManager.default.createDirectory(atPath: laPath, withIntermediateDirectories: true, attributes: nil)
			} catch let error as NSError {
				NSLog("Could not create directory at \(laPath): \(error)")
				return
			}
		}
		
		let plistPath = laPath+"/"+laName+".plist"
		let attributes: [String: Any] = [FileAttributeKey.posixPermissions.rawValue: NSNumber(value: 0o600)]
		do {
			let data = try Data(contentsOf: Bundle.main.url(forResource: laName, withExtension: "plist")!)
			if !FileManager.default.createFile(atPath: plistPath, contents: data, attributes: attributes) {
				NSLog("Could not create plist file at \(plistPath)")
			}
		} catch let error as NSError {
			NSLog("Error getting data of original plist file: \(error)")
		}
	}
	
	
	
	// SUUpdater delegate methods
	func updater(_ updater: SUUpdater!, willInstallUpdate item: SUAppcastItem!) {
		for server in serverManager.servers where server.running {
			_ = server.stopSync()
		}
		for menuApp in NSRunningApplication.runningApplications(withBundleIdentifier: "com.postgresapp.Postgres2MenuHelper") {
			menuApp.terminate()
		}
	}
	
}

