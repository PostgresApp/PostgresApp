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
			}
			if let idx = selectedNavigationElementIndices.first {
				switch navigationElements[idx] {
				case NavigationElement.settings:
					(NSApp.delegate as? AppDelegate)?.showPreferences(nil)
				case NavigationElement.about:
					NSApp.orderFrontStandardAboutPanel(nil)
				default:
					break
				}
			}
			selectedNavigationElementIndices.removeAll()
		}
	}
}

@objc class NavigationElement: NSObject {
	@objc var name: String
	@objc var icon: NSImage
	
	init(name: String, icon: NSImage) {
		self.name = name
		self.icon = icon
	}
	
	static var settings = NavigationElement(name: "Settings", icon: NSImage(systemSymbolName: "gear", accessibilityDescription: nil)!)
	
	static var about = NavigationElement(name: "About", icon: NSImage(systemSymbolName: "info.circle", accessibilityDescription: nil)!)

}
