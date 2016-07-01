//
//  AddServerViewController.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class AddServerViewController: NSViewController, ServerManagerConsumer {
	
	let BUNDLE_PATH = "/Applications/Postgres.app"
	
	dynamic var serverManager: ServerManager!
	dynamic var name: String = "New Server"
	dynamic var port: UInt = 5432
	dynamic var varPath: String = ""
	dynamic var versions: [String] = []
	dynamic var selectedVersionIdx: Int = 0
	
	@IBOutlet var versionsPopup: NSPopUpButton?
	
	
	override func viewDidLoad() {
		self.loadVersions()
		super.viewDidLoad()
	}
	
	
	@IBAction func openChooseFolder(_ sender: AnyObject?) {
		let openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseFiles = false
		openPanel.canChooseDirectories = true
		openPanel.canCreateDirectories = true
		openPanel.directoryURL = self.applicationSupportDirectoryURL(createIfNotExists: true)
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
		
		let server = Server(name: self.name, version: self.versions[self.selectedVersionIdx], port: self.port, varPath: self.varPath)
		serverManager.servers.append(server)
		serverManager.selectedServerIndices = IndexSet(integer:serverManager.servers.indices.last!)
		
		self.dismiss(self)
	}
	
	
	private func loadVersions() {
		func isFinderAlias(url: URL) -> Bool? {
			let aliasUrl = NSURL(fileURLWithPath: url.path!)
			var isAlias:AnyObject? = nil
			do {
				try aliasUrl.getResourceValue(&isAlias, forKey: URLResourceKey.isAliasFileKey)
			} catch _ {}
			return isAlias as! Bool?
		}
		
		let versionsPath = BUNDLE_PATH.appending("/Contents/Versions")
		
		if !FileManager.default().fileExists(atPath: versionsPath) {
			print("Folder \(versionsPath) dosn't exist");
			return
		}
		
		let dirEnum = FileManager.default().enumerator(at: URL.init(fileURLWithPath: versionsPath),
			                                              includingPropertiesForKeys: [URLResourceKey.isSymbolicLinkKey.rawValue, URLResourceKey.isDirectoryKey.rawValue],
			                                              options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles],
			                                              errorHandler: nil
		)
		var versions: [String] = []
		while let url = dirEnum?.nextObject() as? URL {
			if !isFinderAlias(url: url)! {
				versions.append(url.lastPathComponent!)
			}
		}
		
		self.versions = versions
		self.selectedVersionIdx = versions.count-1
	}
	
	
	
	
	private func applicationSupportDirectoryURL(createIfNotExists: Bool) -> URL {
		let appSupportDirURL = URL.init(string:
			String(FileManager.default().urlsForDirectory(.applicationSupportDirectory, inDomains: .userDomainMask)[0]).appending(
				Bundle.main().infoDictionary?[kCFBundleNameKey as String] as! String
			)
		)
		
		if !FileManager.default().fileExists(atPath: appSupportDirURL!.path!) && createIfNotExists {
			do {
				try FileManager.default().createDirectory(at: appSupportDirURL!, withIntermediateDirectories: false, attributes: nil)
			}
			catch let error as NSError  {
				print("Error creating directory: ", error)
			}
		}
		
		return appSupportDirURL!
	}
	
}
