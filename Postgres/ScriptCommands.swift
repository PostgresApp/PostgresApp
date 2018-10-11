//
//  ScriptCommands.swift
//  Postgres
//
//  Created by Chris on 07/02/2017.
//  Copyright © 2017 postgresapp. All rights reserved.
//

import Cocoa

class OpenPrefsScriptCommand: NSScriptCommand {
	override func performDefaultImplementation() -> Any? {
		let delegate = NSApp.delegate as! AppDelegate
		delegate.showPreferences()
		NSApp.activate(ignoringOtherApps: true)
		return true
	}
}

class CheckForUpdatesScriptCommand: NSScriptCommand {
	override func performDefaultImplementation() -> Any? {
		let appDelegate = NSApp.delegate as! AppDelegate
		appDelegate.sparkleUpdater.checkForUpdates(self)
		NSApp.activate(ignoringOtherApps: true)
		return true
	}
}
