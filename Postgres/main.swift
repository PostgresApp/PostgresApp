//
//  main.swift
//  Postgres
//
//  Created by Chris on 13/09/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

UserDefaults.standard.registerPostgresDefaults()

#if !DEBUG
func checkApplicationPath() {
	let actualPath = Bundle.main.bundlePath
	let expectedPath = "/Applications/Postgres.app"
	
	if actualPath != expectedPath {
		let alert = NSAlert()
		alert.messageText = "Postgres.app can't be launched"
		if actualPath.hasPrefix("/Applications/") && !actualPath.hasSuffix("Postgres.app") {
			alert.informativeText = "Please change the name of the app back to 'Postgres.app'."
		} else {
			alert.informativeText = "Please move Postgres.app to your Applications folder.\n\n- use Finder to move the app\n- don't place it in a subfolder\n- don't change the app name"
		}
		alert.addButton(withTitle: "OK")
		alert.runModal()
		exit(1)
	}
}
checkApplicationPath()
#endif


func isFirstLaunch() -> Bool {
	if UserDefaults.standard.bool(forKey: "alreadyLaunched") == false {
		UserDefaults.standard.set(true, forKey: "alreadyLaunched")
		return true
	}
	return false
}


let serverManager = ServerManager.shared

serverManager.loadServers()
if isFirstLaunch() {
	serverManager.checkForExistingDataDirectories()
}
serverManager.createDefaultServer()

let _ = serverManager.addForeignServers(ignoreDeleted: true)

serverManager.refreshServerStatuses()


_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
