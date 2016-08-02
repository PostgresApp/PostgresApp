//
//  SettingsPopoverController.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class SettingsPopoverController: NSViewController, ServerManagerConsumer {
	
	@IBOutlet var serverArrayController: NSArrayController?
	
	dynamic var serverManager: ServerManager!
	dynamic var server: Server? {
		return self.serverArrayController?.selectedObjects.first as? Server
	}
	
	
	
	@IBAction func openDataDirectory(_ sender: AnyObject?) {
		guard let path = self.server?.varPath else { return }
		if !NSWorkspace.shared().selectFile(nil, inFileViewerRootedAtPath: path) {
			let userInfo = [
				NSLocalizedDescriptionKey: "Folder not found.",
				NSLocalizedRecoverySuggestionErrorKey: "It will be created the first time you start the server."
			]
			let error = NSError(domain: "com.postgresapp.Postgres.missing-folder", code: 0, userInfo: userInfo)
			self.dismiss(self)
			NSApp.mainWindow!.windowController?.presentError(error, modalFor: NSApp.mainWindow!, delegate: nil, didPresent: nil, contextInfo: nil)
		}
	}
	
	@IBAction func openConfigFile(_ sender: AnyObject?) {
		guard let path = self.server?.configFilePath else { return }
		if !NSWorkspace.shared().openFile(path, withApplication: "TextEdit") {
			let userInfo = [
				NSLocalizedDescriptionKey: "File not found.",
				NSLocalizedRecoverySuggestionErrorKey: "It will be created the first time you start the server."
			]
			let error = NSError(domain: "com.postgresapp.Postgres.missing-file", code: 0, userInfo: userInfo)
			self.dismiss(self)
			NSApp.mainWindow!.windowController?.presentError(error, modalFor: NSApp.mainWindow!, delegate: nil, didPresent: nil, contextInfo: nil)
		}
	}
	
	@IBAction func openHBAFile(_ sender: AnyObject?) {
		guard let path = self.server?.hbaFilePath else { return }
		if !NSWorkspace.shared().openFile(path, withApplication: "TextEdit") {
			let userInfo = [
				NSLocalizedDescriptionKey: "File not found.",
				NSLocalizedRecoverySuggestionErrorKey: "It will be created the first time you start the server."
			]
			let error = NSError(domain: "com.postgresapp.Postgres.missing-file", code: 0, userInfo: userInfo)
			self.dismiss(self)
			NSApp.mainWindow!.windowController?.presentError(error, modalFor: NSApp.mainWindow!, delegate: nil, didPresent: nil, contextInfo: nil)
		}
	}
	
	@IBAction func openLogFile(_ sender: AnyObject?) {
		guard let path = self.server?.logFilePath else { return }
		if !NSWorkspace.shared().openFile(path, withApplication: "Console") {
			let userInfo = [
				NSLocalizedDescriptionKey: "File not found.",
				NSLocalizedRecoverySuggestionErrorKey: "It will be created the first time you start the server."
			]
			let error = NSError(domain: "com.postgresapp.Postgres.missing-file", code: 0, userInfo: userInfo)
			self.dismiss(self)
			NSApp.mainWindow!.windowController?.presentError(error, modalFor: NSApp.mainWindow!, delegate: nil, didPresent: nil, contextInfo: nil)
		}
	}
	
}
