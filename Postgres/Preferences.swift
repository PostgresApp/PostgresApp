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
		"Postico",
		"TablePlus"
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
	
	@IBAction func resetAppPermissions(_ sender: Any?) {
		UserDefaults.shared.set(nil, forKey: "ClientApplicationPermissions")
	}
	
	@IBAction func updateAppPolicy(_ sender: Any?) {
		guard let popupButton = sender as? NSPopUpButton else {
			NSSound.beep()
			return
		}
		guard let localizedPolicy = popupButton.titleOfSelectedItem else {
			NSSound.beep()
			return
		}
		let policy: String?
		switch localizedPolicy {
		case "Allow": policy = "allow"
		case "Deny": policy = "deny"
		case "Ask": policy = nil
		default: NSSound.beep(); return
		}
		guard let tableView = popupButton.enclosingScrollView?.documentView as? NSTableView else {
			NSSound.beep()
			return
		}
		let editedRow = tableView.row(for: popupButton)
		guard var clientApplicationPermissions = UserDefaults.shared.object(forKey: "ClientApplicationPermissions") as? [[String : Any]] else {
			NSSound.beep()
			return
		}
		guard clientApplicationPermissions.indices.contains(editedRow) else {
			NSSound.beep()
			return
		}
		clientApplicationPermissions[editedRow]["policy"] = policy
		UserDefaults.shared.set(clientApplicationPermissions, forKey: "ClientApplicationPermissions")
	}
	@IBAction func removeClient(_ sender: Any) {
		guard let button = sender as? NSButton else {
			NSSound.beep()
			return
		}
		guard let tableView = button.enclosingScrollView?.documentView as? NSTableView else {
			NSSound.beep()
			return
		}
		let rowToRemove = tableView.row(for: button)
		guard var clientApplicationPermissions = UserDefaults.shared.object(forKey: "ClientApplicationPermissions") as? [[String : Any]] else {
			NSSound.beep()
			return
		}
		guard clientApplicationPermissions.indices.contains(rowToRemove) else {
			NSSound.beep()
			return
		}
		clientApplicationPermissions.remove(at: rowToRemove)
		UserDefaults.shared.set(clientApplicationPermissions, forKey: "ClientApplicationPermissions")
	}
}
