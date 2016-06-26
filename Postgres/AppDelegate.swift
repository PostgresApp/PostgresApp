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
	
	func applicationWillFinishLaunching(_ notification: Notification) {
		self.validateNoOtherVersionsAreRunning()
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		ServerManager.shared.loadServers()
		//ServerManager.shared.startServers()
	}
	
	func applicationDidBecomeActive(_ notification: Notification) {
		
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		ServerManager.shared.saveServers()
	}
	
	func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
		ServerManager.shared.stopServers()
		return NSApplicationTerminateReply.terminateNow
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
	
	
	
	private func validateNoOtherVersionsAreRunning() {
		var runningCopies: [NSRunningApplication] = []
		runningCopies.append(contentsOf: NSRunningApplication.runningApplications(withBundleIdentifier: "com.heroku.postgres"))
		runningCopies.append(contentsOf: NSRunningApplication.runningApplications(withBundleIdentifier: "com.heroku.Postgres"))
		runningCopies.append(contentsOf: NSRunningApplication.runningApplications(withBundleIdentifier: "com.heroku.Postgres93"))
		runningCopies.append(contentsOf: NSRunningApplication.runningApplications(withBundleIdentifier: "com.postgresapp.Postgres"))
		runningCopies.append(contentsOf: NSRunningApplication.runningApplications(withBundleIdentifier: "com.postgresapp.Postgres93"))
		
		for runningCopy in runningCopies {
			if runningCopy != NSRunningApplication.current() {
				let alert = NSAlert()
				alert.messageText = "Another copy of Postgres.app is already running."
				alert.informativeText = "Please quit \(runningCopy.localizedName) before starting this copy."
				alert.addButton(withTitle: "OK")
				alert.runModal()
				NSApp.terminate(nil)
			}
		}
	}
	
}

