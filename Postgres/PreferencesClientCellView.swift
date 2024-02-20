//
//  PreferencesClientCellView.swift
//  Postgres
//
//  Created by Jakob Egger on 19.02.24.
//  Copyright © 2024 postgresapp. All rights reserved.
//

import Cocoa

class PreferencesClientCellView: NSTableCellView {
	
	override var objectValue: Any? {
		set {
			super.objectValue = newValue
			if let objectValue = objectValue as? [String:Any], let path = objectValue["path"] as? String {
				let url = URL(fileURLWithPath: path)
				let bundleURL = url.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
				if bundleURL.pathExtension == "app" {
					let localizedName = try? bundleURL.resourceValues(forKeys: [.localizedNameKey]).localizedName
					clientDisplayName = localizedName ?? bundleURL.deletingPathExtension().lastPathComponent
					clientAppIcon = (try? bundleURL.resourceValues(forKeys: [.effectiveIconKey]).effectiveIcon as? NSImage) ?? (try? url.resourceValues(forKeys: [.effectiveIconKey]).effectiveIcon as? NSImage)
				} else {
					clientDisplayName = url.lastPathComponent
					clientAppIcon = (try? url.resourceValues(forKeys: [.effectiveIconKey]).effectiveIcon as? NSImage)
				}
			} else if let objectValue = objectValue as? [String:Any], let address = objectValue["address"] as? String {
				clientDisplayName = address
				clientAppIcon = NSImage(named: NSImage.networkName)
			} else {
				clientDisplayName = ""
				clientAppIcon = nil
			}
			switch (objectValue as? [String:Any])?["policy"] as? String {
			case "allow": localizedPolicy = "Allow"
			case "deny": localizedPolicy = "Deny"
			default: localizedPolicy = "Ask"
			}
		}
		get {
			super.objectValue
		}
	}
	
	@objc dynamic var clientAppIcon: NSImage?
	@objc dynamic var clientDisplayName: String = ""
	@objc dynamic var localizedPolicy: String = "Ask"
}
