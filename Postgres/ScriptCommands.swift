//
//  ScriptCommands.swift
//  Postgres
//
//  Created by Chris on 07/02/2017.
//  Copyright © 2017 postgresapp. All rights reserved.
//

import Cocoa

class ScriptCommands {
	static let OpenPrefsScriptCommandNotification = Notification.Name("ScriptCommands.OpenPrefsScriptCommandNotification")
	static let CheckForUpdatesScriptCommandNotification = Notification.Name("ScriptCommands.CheckForUpdatesScriptCommandNotification")
}

class OpenPrefsScriptCommand: NSScriptCommand {
	override func performDefaultImplementation() -> Any? {
		NotificationCenter.default.post(name: ScriptCommands.OpenPrefsScriptCommandNotification, object: nil)
		return true
	}
}

class CheckForUpdatesScriptCommand: NSScriptCommand {
	override func performDefaultImplementation() -> Any? {
		NotificationCenter.default.post(name: ScriptCommands.CheckForUpdatesScriptCommandNotification, object: nil)
		return true
	}
}
