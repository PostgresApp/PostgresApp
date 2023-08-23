//
//  Preferences.swift
//  Postgres
//
//  Created by Chris on 31/08/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
	@objc dynamic var clientAppNames = [
		"Terminal",
		"iTerm",
		"Postico"
	]
	
	@objc dynamic var launchAgentCheckboxHidden: Bool {
		if #available(macOS 13, *) {
			return true
		} else {
			return false
		}
	}
	
	@objc dynamic var isTranslocated: Bool {
		Bundle.main.bundlePath.contains("/AppTranslocation/")
	}
}
