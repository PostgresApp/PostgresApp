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
	
	
	func scanForInstallations() -> [Server] {
		var foundServers = [Server]()
		
		for install in foreignPostgresInstalls {
			let binPath = install.binPath
			let varPath = install.varPath
			
			if FileManager.default.fileExists(atPath: binPath) && FileManager.default.fileExists(atPath: varPath) {
				let port = readPortFromConfig(filePath: varPath.appending("/postgresql.conf")) ?? 5432
				let server = Server(name: install.name, port: port, binPath: binPath, varPath: varPath)
				server.isForeign = true
				foundServers.append(server)
			}
		}
		
		return foundServers
	}
	
	
	func readPortFromConfig(filePath: String) -> UInt? {
		guard
			FileManager.default.fileExists(atPath: filePath),
			let testString = try? String(contentsOf: URL(fileURLWithPath: filePath), encoding: .utf8),
			let regex = try? NSRegularExpression(pattern: "\\s*port\\s*=\\s*(\\d+)", options: [])
			else { return nil }
		if
			let match = regex.firstMatch(in: testString, options: [], range: NSMakeRange(0, testString.count)),
			let range = Range(match.range(at: 1), in: testString)
		{
			let res = testString[range]
			return UInt(res)
		}
		return nil
    }
	
}




struct ForeignPostgresInstall {
	var name: String
	var binPath: String
	var varPath: String
}
