//
//  Preferences.swift
//  Postgres
//
//  Created by Chris on 31/08/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
	
	dynamic var iTermFound: Bool {
		return FileManager.default.fileExists(atPath: "/Applications/iTerm.app")
	}
	
	dynamic var useITerm: Bool {
		get {
			return UserDefaults.standard.bool(forKey: "UseITerm")
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "UseITerm")
		}
	}
	
	
	
	
	
}
