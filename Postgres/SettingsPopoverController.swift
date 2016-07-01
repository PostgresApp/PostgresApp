//
//  SettingsPopoverController.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class SettingsPopoverController: NSViewController, ServerManagerConsumer {
	
	dynamic var serverManager: ServerManager!
	
	@IBOutlet var serverArrayController: NSArrayController?
	
	
	@IBAction func openInFinder(_ sender: AnyObject?) {
		if let varPath = (self.serverArrayController?.selectedObjects.first as? Server)?.varPath {
			if NSWorkspace.shared().selectFile(nil, inFileViewerRootedAtPath: varPath) {
				let userInfo: [String: AnyObject] = [
					NSLocalizedDescriptionKey: "Folder not found.",
					NSLocalizedRecoverySuggestionErrorKey: "It will be created the first time you start the server."
				]
				let error = NSError(domain: "com.postgresapp.Postgres.missing-folder", code: 0, userInfo: userInfo)
				self.dismiss(self)
				NSApp.mainWindow!.windowController?.presentError(error, modalFor: NSApp.mainWindow!, delegate: nil, didPresent: nil, contextInfo: nil)
			}
		}
	}
	
	
	
	dynamic var path: NSURL {
		get {
			return NSURL(fileURLWithPath: (self.serverArrayController?.selectedObjects.first!.varPath)!)
		}
	}
	
}
