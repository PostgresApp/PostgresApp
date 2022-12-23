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
		if actualPath.hasPrefix("/Applications/") && !actualPath.hasSuffix("Postgres.app") {
			alert.messageText = "Postgres.app was renamed"
			alert.informativeText = "Please change the name of the app back to 'Postgres.app'."
		}
		else {
			alert.messageText = "Postgres.app was not moved to the Applications folder"
			alert.informativeText = "To ensure that Postgres.app works correctly, please move it to the Applications folder with Finder"
		}
		alert.informativeText = alert.informativeText + "\n\nYou can try to launch Postgres.app anyway, but some things might not work correctly."
		alert.addButton(withTitle: "Quit")
		alert.addButton(withTitle: "Launch anyway")
		let response = alert.runModal()
		if response == .alertFirstButtonReturn {
			exit(1)
		}
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


ServerManager.shared.loadServers()
if isFirstLaunch() {
	ServerManager.shared.checkForExistingDataDirectories()
}
ServerManager.shared.createDefaultServer()
ServerManager.shared.refreshServerStatuses()


_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
