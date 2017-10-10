//
//  maine.swift
//  PostgresLoginHelper
//
//  Created by Chris on 05/09/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

if Bundle.main.bundlePath.hasPrefix("/Applications/Postgres.app") {
	// Launch the menu bar helper
	if UserDefaults.shared.bool(forKey: "HideMenuHelperApp") == false {
		let menuHelperAppURL = URL(fileURLWithPath: "/Applications/Postgres.app/Contents/MacOS/PostgresMenuHelper.app")
		if !NSWorkspace.shared.open(menuHelperAppURL) {
			NSLog("Failed to launch MenuHelperApp")
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
				NSLog("Failed to start server \(server.name): \(error.localizedDescription)")
			}
		}
	}
}
