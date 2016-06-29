//
//  SidebarController.swift
//  Postgres
//
//  Created by Chris on 23/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class SidebarController: NSViewController, ServerManagerConsumer {
	
	dynamic var serverManager: ServerManager!
	
	@IBOutlet var serverArrayController: NSArrayController?
	
	
	override func prepare(for segue: NSStoryboardSegue, sender: AnyObject?) {
		if var target = segue.destinationController as? ServerManagerConsumer {
			target.serverManager = serverManager
		}
	}
	
	
	@IBAction func removeServer(_ sender: AnyObject) {
		let alert = NSAlert()
		alert.messageText = "Delete Server?"
		alert.addButton(withTitle: "OK")
		alert.addButton(withTitle: "Cancel")
		alert.alertStyle = .warning
		alert.beginSheetModal(for: self.view.window!) { (modalResponse) -> Void in
			if modalResponse == NSAlertFirstButtonReturn {
				//self.serverManager?.removeSelectedServer()
				//self.serverArrayController?.removeSelectionIndexes((self.serverArrayController?.selectionIndexes)!)
				//self.serverArrayController?.remove(atArrangedObjectIndexes: ((self.serverArrayController?.selectionIndexes)!))
				self.serverArrayController!.remove(nil)
				self.serverArrayController!.rearrangeObjects()
				print(self.serverArrayController!.content?.count)
			}
		}
		
	}
	
}



class ServerTableCellView: NSTableCellView {
	
	dynamic private(set) var image: NSImage!
	
	
	override func awakeFromNib() {
		self.addObserver(self, forKeyPath: "self.objectValue.running", options: [.new], context: nil)
	}
	
	deinit {
		self.removeObserver(self, forKeyPath: "self.objectValue.running")
	}
	
	
	override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
		switch keyPath! {
		case "self.objectValue.running":
			let imgName = (self.objectValue as? PostgresServer)?.running == true ? NSImageNameStatusAvailable : NSImageNameStatusUnavailable
			self.image = NSImage.init(imageLiteralResourceName: imgName)
			break
		default:
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
		
	}
	
}
