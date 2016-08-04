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
	dynamic var selectedServerIndices = IndexSet()
	
	
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
		let data = NSKeyedArchiver.archivedData(withRootObject: self.servers)
		UserDefaults.standard().set(data, forKey: "servers")
	}
	
	
	func loadServers() {
		let loadServersError = NSError(domain: "", code: 0)
		do {
			guard let data = UserDefaults.standard().data(forKey: "servers") else { throw loadServersError }
			guard let servers = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Server] where !servers.isEmpty else { throw loadServersError }
			self.servers = servers
		} catch {
			self.servers.append(Server(name: "Default Server"))
		}
	}
	
}


protocol ServerManagerConsumer {
	var serverManager: ServerManager! { get set }
}
