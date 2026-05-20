//
//  Preferences.swift
//  Postgres
//
//  Created by Chris on 31/08/2016.
//  This code is released under the terms of the PostgreSQL License.
//

import Cocoa
import ServiceManagement

class PreferencesViewController: NSViewController {
	@IBOutlet var preferredClientMenu: NSPopUpButton!
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		ClientLauncher.shared.prepareClientLauncherButton(button: preferredClientMenu)
	}
	
	@objc dynamic var clientAppNames = [
		"Terminal",
		"iTerm",
		"Postico"
	]
	
	@objc dynamic var launchAtLogin: Bool {
		get {
			if #available(macOS 13, *) {
				if SMAppService.mainApp.status == .enabled {
					return true
				}
				if SMAppService.loginItem(identifier:"com.postgresapp.Postgres2LoginHelper").status == .enabled {
					// login item was registered by previous version of Postgres.app
					return true
				}
				return false
			} else {
				return IsLoginItemRegistered(Bundle.main.bundleURL as CFURL)
			}
		}
		set {
			do {
				if #available(macOS 13, *) {
					if newValue {
						// register login item
						try? SMAppService.loginItem(identifier:"com.postgresapp.Postgres2LoginHelper").unregister()
						try SMAppService.mainApp.register()
					} else {
						// unregister login item
						if SMAppService.mainApp.status == .enabled {
							try SMAppService.mainApp.unregister()
						} else {
							try SMAppService.loginItem(identifier:"com.postgresapp.Postgres2LoginHelper").unregister()
						}
					}
				} else {
					if newValue {
						// register login item
						RegisterLegacyLoginItem(Bundle.main.bundleURL as CFURL)
					} else {
						// unregister login item
						UnregisterLegacyLoginItem(Bundle.main.bundleURL as CFURL)
					}
				}
			}
			catch {
				self.presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
			}
			
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
