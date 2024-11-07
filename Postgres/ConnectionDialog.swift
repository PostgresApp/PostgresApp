//
//  ConnectionDialog.swift
//  Postgres
//
//  Created by Jakob Egger on 21.10.24.
//  Copyright © 2024 postgresapp. All rights reserved.
//

import Cocoa

class ConnectionDialog: NSViewController {
	@objc dynamic var server: Server?

	@IBOutlet weak var databaseComboBox: NSComboBox!
	@IBOutlet weak var userComboBox: NSComboBox!
	@IBOutlet weak var clientAppPopUpButton: NSPopUpButton!
	@IBOutlet weak var rememberClientApp: NSButton!
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		databaseComboBox.completes = true
		databaseComboBox.stringValue = server?.firstSelectedDatabase?.name ?? ""
		databaseComboBox.removeAllItems()
		if let databases = server?.databases, !databases.isEmpty {
			for db in databases {
				databaseComboBox.addItem(withObjectValue: db.name)
			}
		} else {
			databaseComboBox.addItem(withObjectValue: NSUserName())
			databaseComboBox.addItem(withObjectValue: "postgres")
		}
		
		userComboBox.completes = true
		userComboBox.removeAllItems()
		userComboBox.addItem(withObjectValue: NSUserName())
		userComboBox.addItem(withObjectValue: "postgres")
		
		ClientLauncher.shared.prepareClientLauncherButton(button: clientAppPopUpButton, includeAsk: false)
		if let selection = clientAppPopUpButton.selectedItem?.representedObject as? String, selection == UserDefaults.standard.string(forKey: "PreferredClientApplicationPath") {
			rememberClientApp.state = .on
		} else {
			rememberClientApp.state = .off
		}
		if clientAppPopUpButton.selectedItem == nil && clientAppPopUpButton.numberOfItems > 1 {
			clientAppPopUpButton.selectItem(at: 1)
		}
	}
	
	@IBAction func connect(_ sender: Any?) {
		Task {
			do {
				guard let clientPath = clientAppPopUpButton.selectedItem?.representedObject as? String else {
					throw NSError(domain: "com.postgresapp.Postgres2.ConnectionDialog", code: 1, userInfo: [NSLocalizedDescriptionKey: "No client selected"])
				}
				if rememberClientApp.state == .on {
					UserDefaults.standard.set(clientPath, forKey: "PreferredClientApplicationPath")
				} else {
					UserDefaults.standard.removeObject(forKey: "PreferredClientApplicationPath")
				}
				let clientAppURL = URL(fileURLWithPath: clientPath)
				try await ClientLauncher.shared.launchClient(clientAppURL, server: server!, databaseName: databaseComboBox.stringValue, userName: userComboBox.stringValue)
				dismiss(self)
			} catch let error {
				if let window = view.window {
					self.presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
				}
			}
		}
	}
}
