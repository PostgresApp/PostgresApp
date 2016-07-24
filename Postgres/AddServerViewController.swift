//
//  AddServerViewController.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class AddServerViewController: NSViewController, ServerManagerConsumer {
	
	dynamic var serverManager: ServerManager!
	dynamic var name: String = "New Server"
	dynamic var port: UInt = 5432
	dynamic var varPath: String = ""
	dynamic var versions: [String] = []
	dynamic var selectedVersionIdx: Int = 0
	
	@IBOutlet var versionsPopup: NSPopUpButton?
	
	
	override func viewDidLoad() {
		loadVersions()
		super.viewDidLoad()
	}
	
	
	@IBAction func openChooseFolder(_ sender: AnyObject?) {
		var directoryURL = URL(fileURLWithPath: "")
		do {
			try directoryURL = FileManager.default().applicationSupportDirectoryURL(createIfNotExists: true)
		} catch {
			
		}
		
		let openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseFiles = false
		openPanel.canChooseDirectories = true
		openPanel.canCreateDirectories = true
		openPanel.directoryURL = directoryURL
		openPanel.beginSheetModal(for: self.view.window!) { (returnCode) in
			if returnCode == NSModalResponseOK {
				let varTmp = openPanel.url!.path!
				let pgVersionPath = varTmp.appending("/PG_VERSION")
				if !FileManager.default().fileExists(atPath: pgVersionPath) {
					self.varPath = varTmp.appendingFormat("/var-", self.versions[self.selectedVersionIdx])
				} else {
					self.varPath = varTmp
				}
			}
		}
	}
	
	@IBAction func cancel(_ sender: AnyObject?) {
		self.dismiss(self)
	}
	
	@IBAction func createServer(_ sender: AnyObject?) {
		if !(self.view.window?.makeFirstResponder(nil))! { NSBeep(); return }
		
		let server = Server(name: name, version: versions[selectedVersionIdx], port: port, varPath: varPath)
		serverManager.servers.append(server)
		serverManager.selectedServerIndices = IndexSet(integer:serverManager.servers.indices.last!)
		
		self.dismiss(self)
	}
	
	
	private func loadVersions() {
		let versionsPath = AppDelegate.BUNDLE_PATH.appending("/Contents/Versions")
		
		if !FileManager.default().fileExists(atPath: versionsPath) {
			print("Folder \(versionsPath) dosn't exist");
			return
		}
		
		let dirEnum = FileManager.default().enumerator(at: URL(fileURLWithPath: versionsPath),
			                                              includingPropertiesForKeys: [URLResourceKey.isSymbolicLinkKey.rawValue, URLResourceKey.isDirectoryKey.rawValue],
			                                              options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles],
			                                              errorHandler: nil
		)
		while let url = dirEnum?.nextObject() as? URL {
			if !url.isFinderAlias {
				versions.append(url.lastPathComponent!)
			}
		}
		
		selectedVersionIdx = versions.count-1
	}
	
}
