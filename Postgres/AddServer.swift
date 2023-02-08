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
	@objc dynamic var varPath: String = ""
	
	@IBOutlet weak var serverVersionPopUpButton: NSPopUpButton!
	
	var availableBinaries: [PostgresBinary] = []
	@objc dynamic var binaryPath = BinaryManager.shared.getLatestBinary().binPath
		
	
	override func viewWillAppear() {
		loadVersions()
	}
	
	override func viewDidLoad() {
		loadVersions()
		if let selectedBinary = availableBinaries.first(where: { $0.binPath == binaryPath }) {
			varPath = FileManager().applicationSupportDirectoryPath().appending("/var-\(selectedBinary.version)")
		}
		
		super.viewDidLoad()
	}
	
	
	@IBAction func versionChanged(_ sender: AnyObject?) {
		if let selectedBinary = availableBinaries.first(where: { $0.binPath == binaryPath }) {
			let regex = try! NSRegularExpression(pattern: "\\d+(\\.\\d+)?$", options: .caseInsensitive)
			varPath = regex.stringByReplacingMatches(in: varPath, options: [], range: NSRange(0..<varPath.utf16.count), withTemplate: NSRegularExpression.escapedTemplate(for: selectedBinary.version))
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
		
		let server = Server(name: name, binPath: binaryPath, port: port, varPath: varPath)
		mainWindowModel.serverManager.servers.append(server)
		mainWindowModel.selectedServerIndices = IndexSet(integer: mainWindowModel.serverManager.servers.indices.last!)
		
		NotificationCenter.default.post(name: Server.PropertyChangedNotification, object: nil)
		
		self.dismiss(nil)
	}
	
	
	private func loadVersions() {
		availableBinaries = BinaryManager.shared.findAvailableBinaries()
		let menu = NSMenu()
		menu.autoenablesItems = false
		var lastAppURL: URL? = nil
		var currentItem: NSMenuItem? = nil
		for binary in availableBinaries {
			let effectiveAppURL = binary.appURL ?? binary.url
			if effectiveAppURL != lastAppURL {
				let shortPath = effectiveAppURL.path.replacingOccurrences(of:"/Users/\(NSUserName())", with: "~")
				let labelItem = NSMenuItem(title: shortPath, action: nil, keyEquivalent: "")
				labelItem.isEnabled = false
				menu.addItem(labelItem)
				lastAppURL = effectiveAppURL
			}
			let binaryItem = NSMenuItem(title: binary.displayName, action: nil, keyEquivalent: "")
			binaryItem.representedObject = binary.binPath
			if binary.binPath == binaryPath { currentItem = binaryItem }
			menu.addItem(binaryItem)
		}
		serverVersionPopUpButton.autoenablesItems = false
		serverVersionPopUpButton.menu = menu
		if let currentItem { serverVersionPopUpButton.select(currentItem) }
	}
	
}
