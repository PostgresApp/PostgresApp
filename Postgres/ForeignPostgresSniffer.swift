//
//  ForeignPostgresSniffer.swift
//  Postgres
//
//  Created by Chris on 10.10.17.
//  Copyright © 2017 postgresapp. All rights reserved.
//

import Cocoa

class ForeignPostgresSniffer {
	
	private let foreignPostgresInstalls = [
		ForeignPostgresInstall(name: "Homebrew",  binPath: "/usr/local/Cellar/postgresql/9.6.5/bin", varPath: "/usr/local/var/postgres"),
		ForeignPostgresInstall(name: "Mac Ports", binPath: "/opt/local/lib/postgresql96/bin",        varPath: "/opt/local/var/db/postgresql96"),
	]
	
	var foundServers: [Server]?
	
	
	func scanForInstallations(ignoreDeleted: Bool) {
		var foundServers = [Server]()
		
		var removedServers = [String]()
		if let defaults = UserDefaults.standard.array(forKey: "RemovedForeignServers") as? [String] {
			removedServers = defaults
		}
		
		for install in foreignPostgresInstalls {
			let binPath = install.binPath
			let varPath = install.varPath
			
			if ignoreDeleted && removedServers.contains(binPath) {
				continue
			}
			
			if FileManager.default.fileExists(atPath: binPath) && FileManager.default.fileExists(atPath: varPath) {
				let port = readPortFromConfig(filePath: varPath.appending("/postgresql.conf")) ?? 5432
				let server = Server(name: install.name, port: port, binPath: binPath, varPath: varPath)
				server.isForeign = true
				foundServers.append(server)
			}
		}
		
		self.foundServers = foundServers
	}
	
	
	func readPortFromConfig(filePath: String) -> UInt? {
		return nil
	}
	
}



struct ForeignPostgresInstall {
	var name: String
	var binPath: String
	var varPath: String
}
