//
//  LaunchAtLoginManager.swift
//  Postgres
// 
// 
// Created by Jakob on 16.06.26.
// This code is released under the terms of the PostgreSQL License.
// 

import ServiceManagement

extension UserDefaults {
	static let LoginItemWasRegisteredKey = "LoginItemWasRegistered"
}

class LaunchAtLoginManager {
	static var shared = LaunchAtLoginManager()
	
	var isLaunchAtLoginEnabled : Bool {
		if #available(macOS 13, *) {
			if SMAppService.mainApp.status == .enabled {
				return true
			}
			if SMAppService.loginItem(identifier:"com.postgresapp.Postgres2LoginHelper").status == .enabled {
				return true
			}
			return false
		} else {
			return IsLoginItemRegistered(Bundle.main.bundleURL as CFURL)
		}
	}
	
	func registerLoginItem() throws {
		UserDefaults.standard.set(true, forKey: UserDefaults.LoginItemWasRegisteredKey)
		do {
			if #available(macOS 13, *) {
				// clean up login item if necessary
				try? SMAppService.loginItem(identifier:"com.postgresapp.Postgres2LoginHelper").unregister()
				// register main app as login item
				try SMAppService.mainApp.register()
			} else {
				RegisterLegacyLoginItem(Bundle.main.bundleURL as CFURL)
			}
		}
		guard isLaunchAtLoginEnabled else {
			throw LaunchAtLoginManagerError(errorDescription: "Registering login item failed", recoverySuggestion: "Make sure Postgres.app has permission to run in the background in system settings.")
		}
	}
	
	func unregisterLoginItem() throws {
		UserDefaults.standard.set(true, forKey: UserDefaults.LoginItemWasRegisteredKey)
		var errors = [Error]()
		if #available(macOS 13, *) {
			do {
				try SMAppService.loginItem(identifier:"com.postgresapp.Postgres2LoginHelper").unregister()
			} catch {
				errors.append(error)
			}
			do {
				try SMAppService.mainApp.unregister()
			} catch {
				errors.append(error)
			}
		} else {
			UnregisterLegacyLoginItem(Bundle.main.bundleURL as CFURL)
		}
		guard !isLaunchAtLoginEnabled else {
			for error in errors {
				print("Unregistering login item: \(error)")
			}
			throw LaunchAtLoginManagerError(errorDescription: "Failed to unregister login item")
		}
	}

	struct LaunchAtLoginManagerError: LocalizedError {
		var errorDescription: String?
		var recoverySuggestion: String?
	}
	
	func configureLoginItem() {
		if Bundle.main.bundlePath.contains("/AppTranslocation/") {
			return
		}
		
		let laPath = NSHomeDirectory() + "/Library/LaunchAgents/com.postgresapp.Postgres2LoginHelper.plist"
		if FileManager.default.fileExists(atPath: laPath) {
			// found a legacy launch agent
			// migrate it to the new system
			do {
				try FileManager.default.removeItem(atPath: laPath)
				UserDefaults.standard.set(false, forKey: "StartLoginHelper") // prevent legacy postgres.app from re-adding the launch agent
			} catch let error as NSError {
				NSLog("Could not delete launch agent \(laPath): \(error)")
			}
			try? registerLoginItem()
			return
		}
		
		if UserDefaults.standard.bool(forKey: UserDefaults.LoginItemWasRegisteredKey) {
			// we don't want to add it back if it was removed by the user
			return
		}
		
		if #available(macOS 13, *) {
			let loginItemStatus = SMAppService.loginItem(identifier:"com.postgresapp.Postgres2LoginHelper").status
			switch loginItemStatus {
			case .enabled, .requiresApproval:
				// just leave it like it is
				UserDefaults.standard.set(true, forKey: UserDefaults.LoginItemWasRegisteredKey)
				return
			case .notFound, .notRegistered:
				// we can still register it
				break
			@unknown default:
				// not sure what we should do here
				NSLog("Unknown login item status: \(loginItemStatus)")
				break
			}
		}
		
		if UserDefaults.standard.bool(forKey: "StartLoginHelper") == false {
			// this must have been set by a previous version of Postgres.app
			// don't auto-add the login item
			return
		}
		
		try? registerLoginItem()
	}
}
