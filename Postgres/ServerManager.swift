//
//  ServerManager.swift
//  Postgres
//
//  Created by Chris on 23/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Foundation

@objc class ServerManager: NSObject {
	
	private static let _shared = ServerManager()
	
	static func shared() -> ServerManager {
		return _shared
	}
	
	
	dynamic var servers: [Server] = []
	dynamic var selectedServerIndices = IndexSet()
	
	
	func refreshServerStatuses() {
		for server in self.servers {
			server.updateServerStatus()
		}
	}
	
	
	func startServers() {
		for server in self.servers {
			if server.runAtStartup {
				server.start {_ in }
			}
		}
	}
	
	
	func stopServers() {
		for server in self.servers {
			if server.stopAtQuit {
				server.stop {_ in }
			}
		}
	}
	
	
	func saveServers() {
		let data = NSKeyedArchiver.archivedData(withRootObject: self.servers)
		UserDefaults.standard().set(data, forKey: "servers")
	}
	
	
	func loadServers() {
		guard let data = UserDefaults.standard().data(forKey: "servers") else { return }
		guard let servers = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Server] else { return }
		self.servers = servers
	}
	
}


protocol ServerManagerConsumer {
	var serverManager: ServerManager! { get set }
}
