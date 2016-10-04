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
		UserDefaults.standard.set(data, forKey: "Servers")
	}
	
	
	func loadServers() {
		self.servers.removeAll()
		
		NSKeyedUnarchiver.setClass(Server.self, forClassName: "Server")
		let loadServersError = NSError(domain: "", code: 0)
		do {
			guard let defaults = UserDefaults.shared() else { throw loadServersError }
			guard let data = defaults.data(forKey: "Servers") else { throw loadServersError }
			guard let servers = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Server] , !servers.isEmpty else { throw loadServersError }
			self.servers = servers
		} catch {}
	}
	
	
	func createDefaultServer() {
		if servers.isEmpty {
			let version = Bundle.main.object(forInfoDictionaryKey: "LatestStablePostgresVersion") as! String
			servers.append(Server("PostgreSQL \(version)"))
			saveServers()
		}
	}
	
	
	func numberOfRunningServers() -> Int {
		var runningServers = 0
		for server in servers where server.running {
			runningServers += 1
		}
		return runningServers
	}
	
	
	func checkForExistsingDataDirectories() {
		let dataDirsPath = FileManager.default.applicationSupportDirectoryPath()
		guard let dataDirsPathEnum = FileManager().enumerator(at: URL(fileURLWithPath: dataDirsPath), includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]) else { return }
		while let itemURL = dataDirsPathEnum.nextObject() as? URL {
			do {
				let resourceValues = try itemURL.resourceValues(forKeys: [.isDirectoryKey])
				guard resourceValues.isDirectory == true else { continue }
			} catch { continue }
			
			let folderName = itemURL.lastPathComponent
			var dataDirHasServer = false
			for server in servers where server.varPath == folderName {
				dataDirHasServer = true
			}
			
			if !dataDirHasServer {
				let alert = NSAlert()
				alert.messageText = "Detected Data Directory"
				alert.informativeText = "Postgres.app detected the Data Directory \"\(folderName)\" from a previous version. Do you want to import it?"
				alert.addButton(withTitle: "OK")
				alert.addButton(withTitle: "Cancel")
				//alert.runModal()
			}
		}
	}
	
}



extension UserDefaults {
	static func shared() -> UserDefaults? {
		if Bundle.main.bundleIdentifier == "com.postgresapp.Postgres2" {
			return UserDefaults.standard
		} else {
			return UserDefaults(suiteName: "com.postgresapp.Postgres2")
		}
	}
}
