//
//  maine.swift
//  PostgresLoginHelper
//
//  Created by Chris on 05/09/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

if #available(macOS 13, *) {
	// we only need the else clause
} else {
	// on old macOS autostart only works when the app is in /Applications/Postgres.app
	if !Bundle.main.bundlePath.hasPrefix("/Applications/Postgres.app") {
		NSLog("Not in /Applications/Postgres.app")
		exit(0)
	}
}

// Launch the menu bar helper
if UserDefaults.shared.bool(forKey: "HideMenuHelperApp") == false {
	var containingBundleURL = Bundle.main.bundleURL
	repeat {
		containingBundleURL.deleteLastPathComponent()
	} while containingBundleURL.pathComponents.count > 1 &&  containingBundleURL.pathExtension != "app"
	if let containingBundle = Bundle(url: containingBundleURL), let menuHelperURL = containingBundle.url(forAuxiliaryExecutable: "PostgresMenuHelper.app") {
		if !NSWorkspace.shared.launchApplication(menuHelperURL.path) {
			NSLog("Failed to launch PostgresMenuHelper.app")
		}
	} else {
		NSLog("PostgresMenuHelper.app not found")
	}
}

// Start PostgreSQL servers
// This may take a few seconds, so we do this after launching the menu bar helper
let serverManager = ServerManager.shared
serverManager.loadServers()
for server in serverManager.servers {
	if server.startOnLogin {
		do {
			try server.startSync()
		}
		catch let error as NSError {
			Swift.print("Failed to start server \(server.name) because \(error.localizedDescription)")
		}
	}
}
