//
//  ServerManager.swift
//  Postgres
//
//  Created by Chris on 23/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Foundation

class ServerManager: NSObject {
	
	static let shared = ServerManager()
	
	dynamic var servers: [Server] = []
	
	
	func refreshServerStatuses() {
		for server in self.servers {
			server.updateServerStatus()
		}
	}
	
	
	func startServers() {
		for server in self.servers {
			if server.startAtLogin {
				server.start { _ in }
			}
		}
	}
	
	
	func saveServers() {
		NSKeyedArchiver.setClassName("Server", for: Server.self)
		let data = NSKeyedArchiver.archivedData(withRootObject: self.servers)
		UserDefaults.standard().set(data, forKey: "Servers")
	}
	
	
	func loadServers() {
		self.servers.removeAll()
		
		NSKeyedUnarchiver.setClass(Server.self, forClassName: "Server")
		let loadServersError = NSError(domain: "", code: 0)
		do {
			guard let defaults = UserDefaults.shared() else { throw loadServersError }
			guard let data = defaults.data(forKey: "Servers") else { throw loadServersError }
			guard let servers = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Server] where !servers.isEmpty else { throw loadServersError }
			self.servers = servers
		} catch {}
	}
	
	
	func createDefaultServer() {
		if servers.isEmpty {
			servers.append(Server("Postgres"))
			saveServers()
		}
	}
	
}



extension UserDefaults {
	static func shared() -> UserDefaults? {
		if Bundle.main().bundleIdentifier == "com.postgresapp.Postgres" {
			return UserDefaults.standard()
		} else {
			return UserDefaults(suiteName: "com.postgresapp.Postgres")
		}
	}
}
