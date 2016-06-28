//
//  ServerManager.swift
//  Postgres
//
//  Created by Chris on 23/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Foundation

@objc class ServerManager: NSObject {
	
	static let shared = ServerManager()
	
	dynamic var servers: [PostgresServer] = []
	dynamic var selectedServerIndices = IndexSet()
	
	
	func startServers() {
		for server in self.servers {
			server.start {_ in }
		}
	}
	
	
	func stopServers() {
		for server in self.servers {
			server.stop {_ in }
		}
	}
	
	
	func selected() -> PostgresServer? {
		guard let firstIdx = self.selectedServerIndices.first else { return nil }
		return self.servers[firstIdx]
	}
	
	
	func removeSelectedServer() {
		guard let firstIdx = self.selectedServerIndices.first else { return }
		self.servers.remove(at: firstIdx)
	}
	
	
	func selectLast() {
		selectedServerIndices = IndexSet(integer: servers.count-1)
	}
	
	
	func saveServers() {
		let data = NSKeyedArchiver.archivedData(withRootObject: self.servers)
		UserDefaults.standard().set(data, forKey: "servers")
	}
	
	
	func loadServers() {
		guard let data = UserDefaults.standard().data(forKey: "servers") else { return }
		guard let servers = NSKeyedUnarchiver.unarchiveObject(with: data) as? [PostgresServer] else { return }
		self.servers = servers
	}
	
}
