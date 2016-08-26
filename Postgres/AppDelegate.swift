//
//  AppDelegate.swift
//  Postgres
//
//  Created by Chris on 22/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	static var PG_APP_PATH: String {
		return "/Applications/Postgres.app"
	}
	
	let serverManager: ServerManager = ServerManager.shared
	var hideStatusMenu = UserDefaults.standard().bool(forKey: "HideStatusMenu")
	
	
	func applicationWillFinishLaunching(_ notification: Notification) {
		#if !DEBUG
		checkApplicationPath()
		#endif
		
		serverManager.loadServers()
		serverManager.createDefaultServer()
		serverManager.refreshServerStatuses()
	}
	
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		NotificationCenter.default().addObserver(forName: Server.propertyChangedNotification, object: nil, queue: OperationQueue.main()) { _ in
			self.serverManager.saveServers()
		}
		
		NotificationCenter.default().addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: OperationQueue.main()) { _ in
			let hideStatusMenu = UserDefaults.standard().bool(forKey: "HideStatusMenu")
			if hideStatusMenu != self.hideStatusMenu {
				DistributedNotificationCenter.default().postNotificationName(HideStatusMenuChangedNotification, object: nil, userInfo: nil, deliverImmediately: true)
				self.hideStatusMenu = hideStatusMenu
			}
		}
		
		DistributedNotificationCenter.default().addObserver(forName: Server.statusChangedNotification, object: nil, queue: OperationQueue.main()) { _ in
			self.serverManager.refreshServerStatuses()
		}
		
		enableHelperApp(false)
	}
	
	
	func applicationDidBecomeActive(_ notification: Notification) {
		serverManager.refreshServerStatuses()
	}
	
	
	@IBAction func showHelp(_ sender: AnyObject?) {
		NSWorkspace.shared().open(URL(string: "http://postgresapp.com/documentation/")!)
	}
	
	
	private func checkApplicationPath() {
		let actualPath = Bundle.main().bundlePath
		let expectedPath = "/Applications/Postgres.app"
		
		if actualPath != expectedPath {
			let alert = NSAlert()
			
			if !actualPath.hasSuffix("Postgres.app") {
				alert.messageText = "Postgres.app has been renamed."
				alert.informativeText = "Please set the name of the app to 'Postgres.app'."
			} else {
				alert.messageText = "Postgres.app must be inside your Applications folder."
				alert.informativeText = "Please move Postgres.app to the Applications folder."
			}
			
			alert.addButton(withTitle: "OK")
			alert.runModal()
			exit(1)
		}
	}
	
	
	private func enableHelperApp(_ enabled: Bool) {
		let helperAppURL = try! Bundle.main().bundleURL.appendingPathComponent("Contents/Library/LoginItems/PostgresHelper.app")
		if LSRegisterURL(helperAppURL, true) != noErr {
			print("Failed to register HelperApp url")
		}
		if SMLoginItemSetEnabled("com.postgresapp.PostgresHelper", enabled) == false {
			print("Failed to enable HelperApp as login item")
		}
	}
	
}

