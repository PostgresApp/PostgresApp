//
//  maine.swift
//  PostgresLoginHelper
//
//  Created by Chris on 05/09/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

if Bundle.main.bundlePath.hasPrefix("/Applications/Postgres.app") {
	// load and start servers
	let serverManager = ServerManager.shared
	serverManager.loadServers()
	serverManager.startServers()
	
	// launch PostgresMenuHelper
	let menuHelperAppURL = URL(fileURLWithPath: "/Applications/Postgres.app/Contents/MacOS/PostgresMenuHelper.app")
	if !NSWorkspace.shared().open(menuHelperAppURL) {
		print("Failed to launch MenuHelperApp")
	}
}
