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
	
	
	class func _shared() -> ServerManager {
		return ServerManager()
	}
	
	
	func refreshServerStatuses() {
		for server in self.servers {
			let _ = server.serverStatus
		}
	}
	
	
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


protocol ServerManagerConsumer {
	var serverManager: ServerManager! { get set }
}
