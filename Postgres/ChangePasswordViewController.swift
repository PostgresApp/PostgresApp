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
    
    @IBOutlet weak var userField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBAction func changePassword(_ sender: Any) {
        server.changePassword(role: userField.stringValue, newPassword: passwordField.stringValue, { status in
            switch status {
            case .Success:
                self.dismiss(nil)
            case .Failure(let error):
                if let window = self.view.window {
                    self.presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
                } else {
                    NSSound.beep()
                }
            }
        })
    }
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(nil)
    }
}