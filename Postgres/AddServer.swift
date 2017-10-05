//
//  AddServer.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class AddServerViewController: NSViewController, MainWindowModelConsumer {
	
	dynamic var mainWindowModel: MainWindowModel!
	dynamic var name: String = "New Server"
	dynamic var port: UInt = 5432
	dynamic var varPath: String = ""
	dynamic var versions: [String] = []
	dynamic var selectedVersionIdx: Int = 0
	
	private var version: String {
		return versions[selectedVersionIdx]
	}
	
	
	override func viewDidLoad() {
		loadVersions()
		varPath = FileManager().applicationSupportDirectoryPath().appending("/var-\(version)")
		
		super.viewDidLoad()
	}
	
	
	@IBAction func versionChanged(_ sender: AnyObject?) {
		let regex = try! NSRegularExpression(pattern: "\\d+(\\.\\d+)?$", options: .caseInsensitive)
		varPath = regex.stringByReplacingMatches(in: varPath, options: [], range: NSRange(0..<varPath.utf16.count), withTemplate: NSRegularExpression.escapedPattern(for: version))
	}
	
	
	@IBAction func openChooseFolder(_ sender: AnyObject?) {
		let openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseFiles = false
		openPanel.canChooseDirectories = true
		openPanel.canCreateDirectories = true
		openPanel.directoryURL = URL(fileURLWithPath: FileManager().applicationSupportDirectoryPath())
		openPanel.beginSheetModal(for: self.view.window!) { (returnCode) in
			if returnCode == NSModalResponseOK {
				self.varPath = openPanel.url!.path
			}
		}
	}
	
	
	@IBAction func cancel(_ sender: AnyObject?) {
		self.dismiss(nil)
	}
	
	
	@IBAction func createServer(_ sender: AnyObject?) {
		guard self.view.window!.makeFirstResponder(nil) else { NSBeep(); return }
		
		for server in mainWindowModel.serverManager.servers {
			if server.varPath == self.varPath {
				let alert = NSAlert()
				alert.messageText = "The Data Directory is already in use by server \"\(server.name)\"."
				alert.informativeText = "Please choose a different location."
				alert.addButton(withTitle: "OK")
				alert.beginSheetModal(for: self.view.window!)
				return
			}
		}
		
		let server = Server(name: name, version: version, port: port, varPath: varPath)
		mainWindowModel.serverManager.servers.append(server)
		mainWindowModel.selectedServerIndices = IndexSet(integer: mainWindowModel.serverManager.servers.indices.last!)
		
		NotificationCenter.default.post(name: Server.PropertyChangedNotification, object: nil)
		
		self.dismiss(nil)
	}
	
	
	private func loadVersions() {
		guard let versionsPathEnum = FileManager().enumerator(at: URL(fileURLWithPath: Server.VersionsPath), includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]) else { return }
		while let itemURL = versionsPathEnum.nextObject() as? URL {
			do {
				let resourceValues = try itemURL.resourceValues(forKeys: [.isDirectoryKey])
				guard resourceValues.isDirectory == true else { continue }
			} catch { continue }
			let folderName = itemURL.lastPathComponent
			if isPostgresVersion(folderName) {
				versions.append(folderName)
			}
		}
        versions.sort { (a, b) -> Bool in
            return a.compare(b, options:[.numeric], range: a.startIndex ..< a.endIndex, locale: nil) == .orderedAscending
        }
		selectedVersionIdx = versions.count-1
	}
	
	
	private func isPostgresVersion(_ s: String) -> Bool {
		let regex = try! NSRegularExpression(pattern: "\\d+(\\.\\d+)?$", options: .caseInsensitive)
		return regex.numberOfMatches(in: s, options: [], range: NSRange(0..<s.utf16.count)) != 0
	}
	
}
