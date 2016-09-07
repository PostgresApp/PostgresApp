//
//  Preferences.swift
//  Postgres
//
//  Created by Chris on 31/08/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
	
	let preferencesManager = PreferencesManager.shared
	
	let clientAppURLs = [
		URL(fileURLWithPath: "/Applications/Utilities/Terminal.app"),
		URL(fileURLWithPath: "/Applications/iTerm.app"),
		URL(fileURLWithPath: "/Applications/Postico.app")
	]
	
	dynamic var clientAppNames: [String] {
		var result = [String]()
		for app in clientAppURLs {
			result.append(app.deletingPathExtension().lastPathComponent)
		}
		return result
	}
	
	dynamic var selectionIndex = 0 {
		didSet {
			preferencesManager.clientAppURL = clientAppURLs[selectionIndex]
		}
	}
	
}




class PreferencesManager {
	
	static let shared = PreferencesManager()
	
	var clientAppURL: URL!
	
}
