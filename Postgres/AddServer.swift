//
//  AddServer.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class AddServerViewController: NSViewController, MainWindowModelConsumer {
	
	@objc dynamic var mainWindowModel: MainWindowModel!
	@objc dynamic var name: String = "New Server"
	@objc dynamic var port: UInt = 5432
    @objc dynamic var binPath: String = ""
    @objc dynamic var binPathEditable: Bool = false
	@objc dynamic var varPath: String = ""
	
	var availableBinaries: [PostgresBinary] = []
    var customBinPath: String = FileManager().homeDirectoryForCurrentUser.path
    
	@objc dynamic var versions: [String] = []
	@objc dynamic var selectedVersionIdx: Int = 0
    
    
		
	
	override func viewDidLoad() {
		loadVersions()
        if availableBinaries.indices.contains(selectedVersionIdx) {
            binPath = availableBinaries[selectedVersionIdx].binPath
            binPathEditable = false
            varPath = FileManager().applicationSupportDirectoryPath().appending("/var-\(availableBinaries[selectedVersionIdx].version)")
        } else {
            binPath = customBinPath
            binPathEditable = true
            varPath = FileManager().applicationSupportDirectoryPath().appending("/var-custom")
        }
		
		super.viewDidLoad()
	}
	
	
	@IBAction func versionChanged(_ sender: AnyObject?) {
        if availableBinaries.indices.contains(selectedVersionIdx) {
            binPath = availableBinaries[selectedVersionIdx].binPath
            binPathEditable = false
            
            let regex = try! NSRegularExpression(pattern: "\\d+(\\.\\d+)?$", options: .caseInsensitive)
            varPath = regex.stringByReplacingMatches(in: varPath, options: [], range: NSRange(0..<varPath.utf16.count), withTemplate: NSRegularExpression.escapedTemplate(for: availableBinaries[selectedVersionIdx].version))
        } else {
            binPath = customBinPath
            binPathEditable = true
            varPath = FileManager().applicationSupportDirectoryPath().appending("/var-custom")
        }
	}
	
	
	@IBAction func openChooseFolder(_ sender: AnyObject?) {
		let openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseFiles = false
		openPanel.canChooseDirectories = true
		openPanel.canCreateDirectories = true
		openPanel.directoryURL = URL(fileURLWithPath: FileManager().applicationSupportDirectoryPath())
		openPanel.beginSheetModal(for: self.view.window!) { (returnCode) in
			if returnCode == NSApplication.ModalResponse.OK {
				self.varPath = openPanel.url!.path
			}
		}
	}
	
	
	@IBAction func cancel(_ sender: AnyObject?) {
		self.dismiss(nil)
	}
	
	
	@IBAction func createServer(_ sender: AnyObject?) {
		guard self.view.window!.makeFirstResponder(nil) else { NSSound.beep(); return }
        
        let isValid = if availableBinaries.indices.contains(selectedVersionIdx) {
            true
        } else if FileManager().fileExists(atPath: binPath.appending("/postgres")) {
            true
        } else {
            false
        }
        
        guard isValid else {
            NSSound.beep()
            return
        }
        
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
		
		let server = Server(name: name, binPath: binPath, port: port, varPath: varPath)
		mainWindowModel.serverManager.servers.append(server)
		mainWindowModel.selectedServerIndices = IndexSet(integer: mainWindowModel.serverManager.servers.indices.last!)
		
		NotificationCenter.default.post(name: Server.PropertyChangedNotification, object: nil)
		
		self.dismiss(nil)
	}
	
	
	private func loadVersions() {
		availableBinaries = BinaryManager.shared.findAvailableBinaries()
		versions = availableBinaries.map { $0.displayName }
        versions.append("Custom…")
		selectedVersionIdx = versions.count-2
	}
	
}
