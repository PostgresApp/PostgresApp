//
//  SettingsView.swift
//  Postgres
//
//  Created by Chris on 03/08/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
	
	dynamic var server: Server?
	
	
	@IBAction func showDataDirectory(_ sender: AnyObject?) {
		guard let path = self.server?.varPath else { return }
		if !NSWorkspace.shared().selectFile(path, inFileViewerRootedAtPath: "") {
			let userInfo = [
				NSLocalizedDescriptionKey: "Folder not found.",
				NSLocalizedRecoverySuggestionErrorKey: "It will be created the first time you start the server."
			]
			let error = NSError(domain: "com.postgresapp.Postgres2.missing-folder", code: 0, userInfo: userInfo)
			self.presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
		}
	}
	
	@IBAction func showConfigFile(_ sender: AnyObject?) {
		guard let path = self.server?.configFilePath else { return }
		if !NSWorkspace.shared().selectFile(path, inFileViewerRootedAtPath: "") {
			let userInfo = [
				NSLocalizedDescriptionKey: "File not found.",
				NSLocalizedRecoverySuggestionErrorKey: "It will be created the first time you start the server."
			]
			let error = NSError(domain: "com.postgresapp.Postgres2.missing-file", code: 0, userInfo: userInfo)
			self.presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
		}
	}
	
	@IBAction func showHBAFile(_ sender: AnyObject?) {
		guard let path = self.server?.hbaFilePath else { return }
		if !NSWorkspace.shared().selectFile(path, inFileViewerRootedAtPath: "") {
			let userInfo = [
				NSLocalizedDescriptionKey: "File not found.",
				NSLocalizedRecoverySuggestionErrorKey: "It will be created the first time you start the server."
			]
			let error = NSError(domain: "com.postgresapp.Postgres2.missing-file", code: 0, userInfo: userInfo)
			self.presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
		}
	}
	
	@IBAction func openLogFile(_ sender: AnyObject?) {
		guard let path = self.server?.logFilePath else { return }
		if !NSWorkspace.shared().openFile(path, withApplication: "Console") {
			let userInfo = [
				NSLocalizedDescriptionKey: "File not found.",
				NSLocalizedRecoverySuggestionErrorKey: "It will be created the first time you start the server."
			]
			let error = NSError(domain: "com.postgresapp.Postgres2.missing-file", code: 0, userInfo: userInfo)
			self.presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
		}
	}
}
