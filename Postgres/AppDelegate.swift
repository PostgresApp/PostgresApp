//
//  AppDelegate.swift
//  Postgres
//
//  Created by Chris on 22/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	static var PG_APP_PATH: String {
		return "/Applications/Postgres.app"
	}
	
	let serverManager: ServerManager = ServerManager.shared
	
	
	func applicationWillFinishLaunching(_ notification: Notification) {
		#if !DEBUG
		checkApplicationPath()
		#endif
	}
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		serverManager.loadServers()
		NotificationCenter.default().addObserver(forName: Server.ChangeNotificationName, object: nil, queue: OperationQueue.main()) { _ in
			self.serverManager.saveServers()
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
	
	
	@IBAction func updateStatusItem(_ sender: AnyObject?) {
		print("updateStatusItem")
		//DistributedNotificationCenter.default().post(name: StatusItemDidChangeNotificationName, object: nil, userInfo: nil)
		DistributedNotificationCenter.default().postNotificationName(StatusItemDidChangeNotificationName, object: nil, userInfo: nil, deliverImmediately: true)
	}
	
}

