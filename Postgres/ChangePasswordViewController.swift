//
//  ChangePasswordViewController.swift
//  Postgres
//
//  Created by Jakob Egger on 12.04.23.
//  Copyright © 2023 postgresapp. All rights reserved.
//

import Foundation

import Cocoa

class ChangePasswordViewController: NSViewController {
    @objc dynamic var server: Server!
    
    @IBOutlet weak var userField: NSPopUpButton!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBAction func changePassword(_ sender: Any) {
		guard let user = userField.titleOfSelectedItem else {
			NSSound.beep()
			return
		}
        server.changePassword(role: user, newPassword: passwordField.stringValue, { status in
            switch status {
            case .success:
                self.dismiss(nil)
            case .failure(let error):
                if let window = self.view.window {
                    self.presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
                } else {
                    NSSound.beep()
                }
            }
        })
    }
	override func viewWillAppear() {
		do {
			let users = try server.getRolesThatCanLoginSync()
			userField.removeAllItems()
			for user in users {
				userField.addItem(withTitle: user)
			}
			userField.selectItem(withTitle: "postgres")
		} catch let error {
			self.dismiss(nil)
			if let window = NSApp.windows.first {
				self.presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
			}
		}
	}
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(nil)
    }
}
