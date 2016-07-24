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
	
	dynamic var varPathURL: URL? {
		get {
			guard let varPath = (self.serverArrayController?.selectedObjects.first as? Server)?.varPath else { return nil }
			return URL(fileURLWithPath: varPath)
		}
	}
	
	
	@IBAction func openInFinder(_ sender: AnyObject?) {
		guard let varPath = (self.serverArrayController?.selectedObjects.first as? Server)?.varPath else { return }
		if !NSWorkspace.shared().selectFile(nil, inFileViewerRootedAtPath: varPath) {
			let userInfo = [
				NSLocalizedDescriptionKey: "Folder not found.",
				NSLocalizedRecoverySuggestionErrorKey: "It will be created the first time you start the server."
			]
			let error = NSError(domain: "com.postgresapp.Postgres.missing-folder", code: 0, userInfo: userInfo)
			self.dismiss(self)
			NSApp.mainWindow!.windowController?.presentError(error, modalFor: NSApp.mainWindow!, delegate: nil, didPresent: nil, contextInfo: nil)
		}
	}
	
}
