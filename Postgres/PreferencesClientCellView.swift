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
					clientAppIcon = try? bundleURL.resourceValues(forKeys: [.effectiveIconKey]).effectiveIcon as? NSImage
				} else {
					clientDisplayName = path.components(separatedBy: "/").last ?? ""
					clientAppIcon = nil
				}
			} else if let objectValue = objectValue as? [String:Any], let address = objectValue["address"] as? String {
				clientDisplayName = address
				clientAppIcon = nil
			} else {
				clientDisplayName = ""
				clientAppIcon = nil
			}
		}
		get {
			super.objectValue
		}
	}
	
	@objc dynamic var clientAppIcon: NSImage?
	@objc dynamic var clientDisplayName: String = ""
}
