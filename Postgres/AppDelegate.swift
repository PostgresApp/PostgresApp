//
//  AppDelegate.swift
//  Postgres
//
//  Created by Chris on 22/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//
import ServiceManagement
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	static var BUNDLE_PATH: String {
		return "/Applications/Postgres.app"
	}
	
	let serverManager: ServerManager = ServerManager.shared
	
	
	func applicationWillFinishLaunching(_ notification: Notification) {
		checkApplicationPath()
		checkOtherVersionsRunning()
	}
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		serverManager.loadServers()
		serverManager.startServers()
	}
	
	func applicationDidBecomeActive(_ notification: Notification) {
		serverManager.refreshServerStatuses()
	}
	
	func applicationWillTerminate(_ notification: Notification) {
		serverManager.saveServers()
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
	
	
	private func checkOtherVersionsRunning() {
		let bundleIdentifiers = [
			"com.heroku.postgres",
			"com.heroku.Postgres",
			"com.heroku.Postgres93",
			"com.postgresapp.Postgres",
			"com.postgresapp.Postgres93"
		]
		
		var runningCopies: [NSRunningApplication] = []
		for bundleID in bundleIdentifiers {
			runningCopies.append(contentsOf: NSRunningApplication.runningApplications(withBundleIdentifier: bundleID))
		}
		
		for runningCopy in runningCopies {
			if runningCopy != NSRunningApplication.current() {
				let alert = NSAlert()
				alert.messageText = "Another copy of Postgres.app is already running."
				alert.informativeText = "Please quit \(runningCopy.localizedName!) before starting this copy."
				alert.addButton(withTitle: "OK")
				alert.runModal()
				exit(1)
			}
		}
	}
	
}

