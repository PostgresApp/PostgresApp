//
//  AppDelegate.swift
//  Postgres
//
//  Created by Chris on 22/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa
import Sparkle
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate, SUUpdaterDelegate, NSAlertDelegate {
	
	let serverManager: ServerManager = ServerManager.shared
	var hideMenuHelperApp = UserDefaults.standard.bool(forKey: "HideMenuHelperApp")
	var startLoginHelper = UserDefaults.standard.bool(forKey: "StartLoginHelper")
	
	@IBOutlet var sparkleUpdater: SUUpdater!
	@IBOutlet var preferencesMenuItem: NSMenuItem!
		
	func isFirstLaunch() -> Bool {
		if UserDefaults.standard.bool(forKey: "alreadyLaunched") == false {
			UserDefaults.standard.set(true, forKey: "alreadyLaunched")
			return true
		}
		return false
	}
	
	func isTranslocated() -> Bool {
		Bundle.main.bundlePath.contains("/AppTranslocation/")
	}
	
	func applicationDidFinishLaunching(_ notification: Notification) {
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
					NSWorkspace.shared.launchApplication(url.path)
				}
			}
			if #available(macOS 13, *) {
				// this setting was removed in macOS 13
				// since we try to register the login item in any case
				// user can enable / disable login item in system settings
			} else {
				let startLoginHelper = UserDefaults.standard.bool(forKey: "StartLoginHelper")
				if self.startLoginHelper != startLoginHelper {
					self.startLoginHelper = startLoginHelper
					if self.startLoginHelper {
						self.createLaunchAgent()
					} else {
						self.destroyLaunchAgent()
					}
				}
			}
		}

		if !isTranslocated() {
			if #available(macOS 13, *) {
				destroyLaunchAgent()
				registerLoginItem()
			} else {
				if startLoginHelper {
					createLaunchAgent()
				} else {
					destroyLaunchAgent()
				}
			}
			
			if UserDefaults.standard.bool(forKey: "HideMenuHelperApp") == false {
				let url = Bundle.main.url(forAuxiliaryExecutable: "PostgresMenuHelper.app")!
				NSWorkspace.shared.launchApplication(url.path)
				NSApp.activate(ignoringOtherApps: true)
			}
		}
		
		for server in serverManager.servers where server.startOnLogin && server.serverStatus == .Startable {
			server.start { _ in }
		}
	}
	
	func applicationDidBecomeActive(_ notification: Notification) {
		serverManager.refreshServerStatuses()
	}
	
	func showPreferences() {
		// The preference window is displayed by a storyboard segue hooked up to a menu item
		// This seems to be the easiest way to trigger that segue programmatically
		NSApp.sendAction(preferencesMenuItem.action!, to: preferencesMenuItem.target, from: preferencesMenuItem)
	}
	
	@IBAction func openHelp(_ sender: AnyObject?) {
		NSWorkspace.shared.open(URL(string: "https://postgresapp.com/l/help/")!)
	}
	
	
	@available(macOS 13, *) private func registerLoginItem() {
		let loginHelper = SMAppService.loginItem(identifier:"com.postgresapp.Postgres2LoginHelper")
		do {
			try loginHelper.register()
		} catch let error {
			// This most likely means that the user disabled the login item in system setting
			// We ignore the error, but print it to stdout for easier debugging
			print("Failed to register login item because: \(error)")
		}
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
		let attributes: [FileAttributeKey: Any] = [.posixPermissions: 0o600]
		do {
			let data = try Data(contentsOf: Bundle.main.url(forResource: laName, withExtension: "plist")!)
			if !FileManager.default.createFile(atPath: plistPath, contents: data, attributes: attributes) {
				NSLog("Could not create plist file at \(plistPath)")
			}
		} catch let error as NSError {
			NSLog("Error getting data of original plist file: \(error)")
		}
	}
	
	private func destroyLaunchAgent() {
		let laPath = NSHomeDirectory().appending("/Library/LaunchAgents")
		let laName = "com.postgresapp.Postgres2LoginHelper"
		let plistPath = laPath+"/"+laName+".plist"
		if FileManager.default.fileExists(atPath: laPath) {
			do {
				try FileManager.default.removeItem(atPath: plistPath)
			} catch let error as NSError {
				NSLog("Could not delete launch agent \(laPath): \(error)")
			}
		}
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
	
	func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
		if isTranslocated() {
			for server in serverManager.servers where server.running && server.binPath.hasPrefix(Bundle.main.bundlePath) {
				try? server.stopSync()
			}
		}
		return .terminateNow
	}
}
