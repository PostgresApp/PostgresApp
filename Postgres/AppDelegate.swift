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
	}
	
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		serverManager.loadServers()
		if serverManager.servers.isEmpty {
			serverManager.servers.append(Server("Default Server"))
			serverManager.saveServers()
		}
		
		NotificationCenter.default().addObserver(forName: Server.changedNotification, object: nil, queue: OperationQueue.main()) { _ in
			self.serverManager.saveServers()
		}
		
		NotificationCenter.default().addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: OperationQueue.main()) { _ in
			let hideStatusMenu = UserDefaults.standard().bool(forKey: "HideStatusMenu")
			if self.hideStatusMenu != hideStatusMenu {
				DistributedNotificationCenter.default().postNotificationName(HideStatusMenuChangedNotification, object: nil, userInfo: nil, deliverImmediately: true)
				self.hideStatusMenu = hideStatusMenu
			}
		}
		
		if !SMLoginItemSetEnabled("com.postgresapp.PostgresHelper", true) {
			print("Failed to enable HelperApp as login item")
		}
	}
	
	
	func applicationDidBecomeActive(_ notification: Notification) {
		serverManager.refreshServerStatuses()
	}
	
	
	private func checkApplicationPath() {
		let actualPath = Bundle.main().bundlePath
		let expectedPath = "/Applications/Postgres.app"
		
		if actualPath != expectedPath {
			
			let wrapper = ASWrapper(fileName: "ASSubroutines")
			do {
				try wrapper.runSubroutine("moveToFolder", parameters: [actualPath, expectedPath])
			} catch let error as NSError {
				print(error)
				let alert = NSAlert()
				alert.messageText = "Could not move Postgres.app."
				alert.informativeText = "Please move Postgres.app to the Applications folder manually."
				alert.addButton(withTitle: "OK")
				alert.runModal()
				exit(1)
			}
		}
	}
	
}

