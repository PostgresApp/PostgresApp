//
//  ClientLauncher.swift
//  Postgres
//
//  Created by Chris on 13/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class ClientLauncher: NSObject {
	
	static let shared = ClientLauncher()
	
	private let scriptPath = "ClientLauncher"
	
	
	func runSubroutine(_ subroutine: String, parameters: [String]?) throws {
		guard let path = Bundle.main.path(forResource: scriptPath, ofType: "scpt") else { return }
		
		// these constants are defined in Carbon (no need to include)
		let kASAppleScriptSuite = FourCharCode("ascr")
		let kASSubroutineEvent = FourCharCode("psbr")
		let keyASSubroutineName = FourCharCode("snam")
		
		var errorDict: NSDictionary?
		
		let script = NSAppleScript(contentsOf: URL(fileURLWithPath: path), error: &errorDict)
		let paramDescr = NSAppleEventDescriptor.list()
		
		if let parameters = parameters {
			var idx = 1
			for p in parameters {
				paramDescr.insert(NSAppleEventDescriptor(string: p), at: idx)
				idx += 1
			}
		}
		
		let eventDescr = NSAppleEventDescriptor.appleEvent(withEventClass: kASAppleScriptSuite, eventID: kASSubroutineEvent, targetDescriptor: NSAppleEventDescriptor.null(), returnID: AEReturnID(kAutoGenerateReturnID), transactionID: AETransactionID(kAnyTransactionID))
		eventDescr.setDescriptor(NSAppleEventDescriptor(string: subroutine), forKeyword: keyASSubroutineName)
		eventDescr.setDescriptor(paramDescr, forKeyword: keyDirectObject)
		script?.executeAppleEvent(eventDescr, error: &errorDict)
		
		if let errorDict = errorDict {
			var userInfo = errorDict as! [String : Any]
			if userInfo[NSLocalizedDescriptionKey] == nil {
				userInfo[NSLocalizedDescriptionKey] = "Failed to open client application"
			}
			if userInfo[NSLocalizedRecoverySuggestionErrorKey] == nil {
				var suggestion = "Make sure Postgres.app has permission to automate the client application."
				if let command = parameters?.first {
					suggestion += "\n\nIf you don't want to give Postgres.app permission, run this command to connect:\n\(command)"
				}
				userInfo[NSLocalizedRecoverySuggestionErrorKey] = suggestion
			}
			throw NSError(domain: "com.postgresapp.Postgres2.ClientLauncher", code: 0, userInfo: userInfo)
		}
	}
	
	// These are Terminal apps that support AppleScript
	// Unfortunately, they don't support the same commands,
	// so we have separate scripts for each of them
	static let scriptableTerminalApps = [
		"com.apple.Terminal",
		"com.googlecode.iterm2",
	]
	
	// These are Terminal apps that do not support AppleScript,
	// but they support opening shell scripts
	static let unscriptableTerminalApps = [
		"com.mitchellh.ghostty",
		"co.zeit.hyper",
		"net.kovidgoyal.kitty",
		"com.github.wez.wezterm",
		"dev.warp.Warp-Stable",
	]

	func prepareClientLauncherButton(button: NSPopUpButton) {
		let postgresURL = URL(string: "postgres:")!
		var appURLs = [URL]()
		if #available(macOS 12, *) {
			for bundleIdentifier in Self.scriptableTerminalApps + Self.unscriptableTerminalApps {
				appURLs += NSWorkspace.shared.urlsForApplications(withBundleIdentifier: bundleIdentifier)
			}
			appURLs += NSWorkspace.shared.urlsForApplications(toOpen: postgresURL)
		} else {
			for bundleIdentifier in Self.scriptableTerminalApps + Self.unscriptableTerminalApps {
				LSCopyApplicationURLsForBundleIdentifier(bundleIdentifier as CFString, nil).map { appURLs += $0.takeRetainedValue() as! [URL] }
			}
			LSCopyApplicationURLsForURL(postgresURL as CFURL, [.viewer,.editor]).map { appURLs += $0.takeRetainedValue() as! [URL] }
		}
		var bundleIdentifiers = Set<String>()
		button.menu?.removeAllItems()
		var items = [NSMenuItem]()
		var selectedItem: NSMenuItem?
		for appURL in appURLs {
			if let bundle = Bundle(url: appURL),
			   let identifier = bundle.bundleIdentifier
			{
				//if bundleIdentifiers.contains(identifier) { continue }
				bundleIdentifiers.insert(identifier)
				let localizedName = bundle.localizedInfoDictionary?[kCFBundleNameKey as String] as? String ?? bundle.infoDictionary?[kCFBundleNameKey as String] as? String ?? appURL.deletingPathExtension().lastPathComponent
				let item = NSMenuItem(title: localizedName, action: nil, keyEquivalent: "")
				let attrTitle = NSMutableAttributedString()
				if #available(macOS 11, *) {
					attrTitle.append(NSAttributedString(string: localizedName, attributes: [
						.font: NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .large)),
					]))

				} else {
					attrTitle.append(NSAttributedString(string: localizedName, attributes: [
						.font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
					]))

				}
				attrTitle.append(NSAttributedString(string: "\n" + appURL.path, attributes: [
					.font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
					.foregroundColor: NSColor.secondaryLabelColor
				]))
				item.attributedTitle = attrTitle
				item.representedObject = appURL.path
				item.image = NSWorkspace.shared.icon(forFile: appURL.path)
				items.append(item)
				if appURL.path == UserDefaults.standard.string(forKey: "PreferredClientApplicationPath") {
					selectedItem = item
				}
			}
		}
		button.menu?.items = items
		button.select(selectedItem ?? items.first)
	}
	
	func launchClient(_ appURL: URL, server: Server, databaseName: String = "", userName: String = "") async throws {
		guard let bundle = Bundle(url: appURL) else {
			throw NSError(domain: "com.postgresapp.Postgres2.ClientLauncher", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("The client application was not found at \(appURL.path).", comment: "")])
		}
		if let checkPath = bundle.executablePath {
			// make sure client is allowed to connect without password
			var clientApplicationPermissions: [[String: Any]]
			clientApplicationPermissions = UserDefaults.shared.object(forKey: "ClientApplicationPermissions") as? [[String : Any]] ?? []
			var isAllowed = false
			for client in clientApplicationPermissions {
				if let path = client["path"] as? String, path == checkPath {
					if let policy = client["policy"] as? String {
						if policy == "allow" {
							isAllowed = true
						}
					}
				}
			}
			if !isAllowed {
				clientApplicationPermissions.removeAll { $0["path"] as? String == checkPath }
				clientApplicationPermissions.append(["path":checkPath, "policy": "allow"])
				UserDefaults.shared.set(clientApplicationPermissions, forKey: "ClientApplicationPermissions")
			}
		}
		if let bundleIdentifier = bundle.bundleIdentifier, Self.scriptableTerminalApps.contains(bundleIdentifier) || Self.unscriptableTerminalApps.contains(bundleIdentifier) {
			var psqlCommand = "\"\(server.binPath)/psql\" -p\(server.port)"
			if !userName.isEmpty { psqlCommand += " -U \"\(userName)\""}
			if !databaseName.isEmpty { psqlCommand += " \"\(databaseName)\""}

			if Self.unscriptableTerminalApps.contains(bundleIdentifier) {
				let commandUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("open_psql.command")
				try psqlCommand.write(to: commandUrl, atomically: false, encoding: .utf8)
				try FileManager().setAttributes([.posixPermissions: 0o700], ofItemAtPath: commandUrl.path)
				if bundleIdentifier == "com.github.wez.wezterm" {
					// This is a Workaround for bug in wezterm
					// opening shell scripts seems to work only if the app is already open
					// so we open it first
					try await NSWorkspace.shared.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration())
				}
				try await NSWorkspace.shared.open([commandUrl], withApplicationAt: appURL, configuration: NSWorkspace.OpenConfiguration())
			}
			else if bundle.bundleIdentifier == "com.apple.Terminal" {
				try self.runSubroutine("open_Terminal", parameters: [psqlCommand])
			}
			else if bundle.bundleIdentifier == "com.googlecode.iterm2" {
				try self.runSubroutine("open_iTerm", parameters: [psqlCommand])
			}
		}
		else {
			var components = URLComponents()
			components.scheme = "postgres"
			if !userName.isEmpty { components.user = userName }
			if !databaseName.isEmpty { components.path = "/" + databaseName }
			components.host = "localhost"
			components.port = Int(server.port)
			let connectionURL = components.url!
			try await NSWorkspace.shared.open([connectionURL], withApplicationAt: appURL, configuration: NSWorkspace.OpenConfiguration())
		}
	}
}


private extension FourCharCode {
	init(_ string: String) {
		self = 0
		for char in string.utf16 {
			self = (self << 8) + FourCharCode(char)
		}
	}
}
