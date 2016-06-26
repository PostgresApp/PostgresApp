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
	dynamic var selectedServerIndices = NSMutableIndexSet()
	
	func startServers() {
		for server in self.servers {
			server.start(completionHandler: { (success, error) in
			})
		}
	}
	
	
	func stopServers() {
		for server in self.servers {
			server.stop(completionHandler: { (success, error) in
			})
		}
	}
	
	
	func selected() -> PostgresServer {
		return self.servers[self.selectedServerIndices.firstIndex]
	}
	
	func removeSelectedServer() {
		self.servers.remove(at: self.selectedServerIndices.firstIndex)
	}
	
	func selectLast() {
		let idxSet = NSMutableIndexSet()
		idxSet.add(servers.count-1)
		selectedServerIndices = idxSet
	}
	
	
	func saveServers() {
		NSKeyedArchiver.setClassName("PostgresServer", for: PostgresServer.self)
		
		let data = NSKeyedArchiver.archivedData(withRootObject: self.servers)
		UserDefaults.standard().set(data, forKey: "servers")
	}
	
	
	func loadServers() {
		NSKeyedUnarchiver.setClass(PostgresServer.self, forClassName: "PostgresServer")
		
		guard let data = UserDefaults.standard().data(forKey: "servers") else { return }
		guard let servers = NSKeyedUnarchiver.unarchiveObject(with: data) as? [PostgresServer] else { return }
		self.servers = servers
	}
	
}
