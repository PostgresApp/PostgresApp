//
//  ServerManager.swift
//  Postgres
//
//  Created by Chris on 23/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class ServerManager: NSObject {
	
	static let shared = ServerManager()
	
	@objc dynamic var servers: [Server] = []
	
	
	func refreshServerStatuses() {
		for server in servers {
			server.updateServerStatus()
		}
	}
	
	func saveServers() {
		var plists: [[AnyHashable: Any]] = []
		for server in servers {
			plists.append(server.asPropertyList)
		}
		UserDefaults.standard.set(plists, forKey: "Servers")
	}
	
	
	func loadServers() {
		servers.removeAll()
		guard let plists = UserDefaults.shared.array(forKey: "Servers") as? [[AnyHashable: Any]] else {
			NSLog("PostgresApp could not load servers from user defaults.")
			return
		}
		for plist in plists {
			guard let server = Server(propertyList: plist) else {
				NSLog("PostgresApp could not load server from user defaults.")
				continue
			}
			servers.append(server)
		}
	}
}

