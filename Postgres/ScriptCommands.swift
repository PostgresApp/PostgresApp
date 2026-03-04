//
//  ScriptCommands.swift
//  Postgres
//
//  Created by Chris on 07/02/2017.
//  This code is released under the terms of the PostgreSQL License.
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
