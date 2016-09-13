//
//  main.swift
//  Postgres
//
//  Created by Chris on 13/09/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

#if !DEBUG
func checkApplicationPath() {
	let actualPath = Bundle.main.bundlePath
	let expectedPath = "/Applications/Postgres.app"
	
	if actualPath != expectedPath {
		let alert = NSAlert()
		
		if !actualPath.hasSuffix("Postgres.app") {
			alert.messageText = "Postgres.app has been renamed."
			alert.informativeText = "Please set the name of the app to 'Postgres.app'."
		} else {
			alert.messageText = "Postgres.app must be inside your Applications folder."
			alert.informativeText = "Please move Postgres.app to the Applications folder."
		}
		
		alert.addButton(withTitle: "OK")
		alert.runModal()
		exit(1)
	}
}
checkApplicationPath()
#endif


ServerManager.shared.loadServers()
ServerManager.shared.createDefaultServer()
ServerManager.shared.refreshServerStatuses()


_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
