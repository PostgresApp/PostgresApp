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
	
	private var version: String {
		return versions[selectedVersionIdx]
	}
	
	@IBOutlet var versionsPopup: NSPopUpButton?
	
	
	override func viewDidLoad() {
		loadVersions()
		if let path = FileManager().applicationSupportDirectoryPath(createIfNotExists: true) {
			self.varPath = path.appending("/var-\(self.version)")
		}
		super.viewDidLoad()
	}
	
	
	@IBAction func versionChanged(_ sender: AnyObject?) {
		self.varPath = self.varPath.replacingOccurrences(of: "\\d+(\\.\\d+)?$", with: RegularExpression.escapedTemplate(for: self.version), options: .regularExpressionSearch)
	}
	
	
	@IBAction func openChooseFolder(_ sender: AnyObject?) {
		let openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseFiles = false
		openPanel.canChooseDirectories = true
		openPanel.canCreateDirectories = true
		if let path = FileManager().applicationSupportDirectoryPath(createIfNotExists: true) {
			openPanel.directoryURL = URL(fileURLWithPath: path)
		}
		openPanel.beginSheetModal(for: self.view.window!) { (returnCode) in
			if returnCode == NSModalResponseOK {
				self.varPath = openPanel.url!.path!
			}
		}
	}
	
	
	@IBAction func cancel(_ sender: AnyObject?) {
		self.dismiss(self)
	}
	
	
	@IBAction func createServer(_ sender: AnyObject?) {
		guard self.view.window!.makeFirstResponder(nil) else { NSBeep(); return }
		
		for server in self.serverManager.servers {
			if server.varPath == self.varPath {
				let alert = NSAlert()
				alert.messageText = "The Data Directory is already in use by server \"\(server.name)\"."
				alert.informativeText = "Please choose a different location."
				alert.addButton(withTitle: "OK")
				alert.beginSheetModal(for: self.view.window!)
				return
			}
		}
		
		let server = Server(name: self.name, version: self.version, port: self.port, varPath: self.varPath)
		serverManager.servers.append(server)
		serverManager.selectedServerIndices = IndexSet(integer:serverManager.servers.indices.last!)
		
		self.dismiss(self)
	}
	
	
	private func loadVersions() {
		let versionsPath = AppDelegate.BUNDLE_PATH.appending("/Contents/Versions")
		guard let dirEnum = FileManager().enumerator(at: URL(fileURLWithPath: versionsPath),
			                                              includingPropertiesForKeys: [URLResourceKey.isDirectoryKey.rawValue],
			                                              options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]
		) else { return }
		while let url = dirEnum.nextObject() as? URL {
			do {
				let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
				guard resourceValues.isDirectory == true else { continue }
			} catch { continue }
			versions.append(url.lastPathComponent!)
		}
		self.selectedVersionIdx = versions.count-1
	}
	
}



private extension FileManager {
	func applicationSupportDirectoryPath(createIfNotExists: Bool) -> String? {
		guard let url = self.urlsForDirectory(.applicationSupportDirectory, inDomains: .userDomainMask).first else { return nil }
		let bundleName = Bundle.main().objectForInfoDictionaryKey(kCFBundleNameKey as String) as! String
		let path = try! url.appendingPathComponent(bundleName).path!
		
		if !self.fileExists(atPath: path) && createIfNotExists {
			do {
				try self.createDirectory(atPath: path, withIntermediateDirectories: false)
			}
			catch {
				return nil
			}
		}
		
		return path
	}
}
