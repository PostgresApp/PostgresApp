//
//  MainWindowModel.swift
//  Postgres
//
//  Created by Chris on 17/08/2016.
//  This code is released under the terms of the PostgreSQL License.
//

import Cocoa

class MainWindowModel: NSObject {
	static var shared = MainWindowModel()
	
	@objc dynamic var serverManager = ServerManager.shared
	@objc dynamic var selectedServerIndices = IndexSet() {
		didSet {
			if selectedServerIndices != oldValue {
				firstSelectedServer?.updateServerStatus()
				firstSelectedServer?.checkReindexWarning()
			}
			if !selectedServerIndices.isEmpty {
				selectedNavigationElementIndices.removeAll()
				selectedTabIdentifier = "ServerTab"
			}
		}
	}
	
	var firstSelectedServer: Server? {
		guard let selIdx = selectedServerIndices.first else { return nil }
		return serverManager.servers[selIdx]
	}
	
	func removeSelectedServer() {
		guard let selIdx = selectedServerIndices.first else { return }
		serverManager.servers.remove(at: selIdx)
		
		if selIdx > 0 {
			selectedServerIndices = IndexSet(integer: selIdx-1)
		} else if !serverManager.servers.isEmpty {
			selectedServerIndices = IndexSet(integer: 0)
		} else {
			selectedServerIndices = IndexSet()
		}
	}
	
	@objc dynamic var navigationElements = [
		NavigationElement.settings,
		NavigationElement.about
	]
	
	@objc dynamic var selectedNavigationElementIndices = IndexSet() {
		didSet {
			if !selectedNavigationElementIndices.isEmpty {
				selectedServerIndices.removeAll()
				selectedTabIdentifier = navigationElements[selectedNavigationElementIndices.first!].identifier
			}
		}
	}
	
	@objc dynamic var selectedTabIdentifier = "ServerTab"
}

@objc class NavigationElement: NSObject {
	@objc var name: String
	@objc var icon: NSImage
	@objc var identifier: String
	
	init(name: String, icon: NSImage, identifier: String) {
		self.name = name
		self.icon = icon
		self.identifier = identifier
	}
	
	static var settings = NavigationElement(name: "Settings", icon: NSImage(systemSymbolName: "gear", accessibilityDescription: nil)!, identifier: "SettingsTab")
	static var about = NavigationElement(name: "About", icon: NSImage(systemSymbolName: "info.circle", accessibilityDescription: nil)!, identifier: "AboutTab")

}
