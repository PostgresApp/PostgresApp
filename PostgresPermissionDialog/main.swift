//
//  main.swift
//  PostgresPermissionDialog
//
//  Created by Jakob Egger on 22.05.23.
//  Copyright © 2023 postgresapp. All rights reserved.
//

import AppKit



var args = CommandLine.arguments

var pid: pid_t?
var clientAddr: String?
var clientPort: Int?
var serverAddr: String?
var serverPort: Int?
while let arg = args.first {
	args.removeFirst()
	if arg == "--client-pid" {
		pid = pid_t(args.removeFirst())
	}
	if arg == "--client-addr" {
		clientAddr = args.removeFirst()
	}
	if arg == "--client-port" {
		clientPort = Int(args.removeFirst())
	}
	if arg == "--server-addr" {
		serverAddr = args.removeFirst()
	}
	if arg == "--server-port" {
		serverPort = Int(args.removeFirst())
	}

}

guard let pid else {
	fputs("Usage: \(CommandLine.arguments.first ?? "PostgresPermissionDialog") --client-pid 12345\n", stderr)
	exit(2);
}

var clientApplicationPermissions: [[String: Any]]
clientApplicationPermissions = UserDefaults.shared.object(forKey: "ClientApplicationPermissions") as? [[String : Any]] ?? []

do {
	let process = try UnixProcessInfo(runningProcessWithPid: pid)
	let topLevelProcess = process.getTopLevelProcess()

	let selfInfo = try UnixProcessInfo(runningProcessWithPid: ProcessInfo.processInfo.processIdentifier)
	let selfContainingDirectory = (selfInfo.path as NSString).deletingLastPathComponent
	if (topLevelProcess.path.hasPrefix(selfContainingDirectory)) {
		exit(0)
	}
	
	// check user defaults
	for client in clientApplicationPermissions {
		if let path = client["path"] as? String, path == topLevelProcess.path {
			if let policy = client["policy"] as? String {
				if policy == "allow" {
					exit(0)
				} else {
					fputs("Connection attempt from \(topLevelProcess.name) denied by Postgres.app settings.\n", stderr)
					exit(1)
				}
			}
		}
	}

	NSApplication.shared.setActivationPolicy(.accessory)
	NSApplication.shared.activate(ignoringOtherApps: true)

	let alert = NSAlert()

	alert.messageText = "“\(topLevelProcess.name)” wants to connect to Postgres.app without using a password"
	alert.informativeText = "You can reset permissions later in Postgres.app settings."

	alert.addButton(withTitle: "OK")
	alert.addButton(withTitle: "Don't Allow")

	let result = alert.runModal()

	switch result {
	case .alertFirstButtonReturn:
		clientApplicationPermissions.append(["path":topLevelProcess.path, "policy": "allow"])
		UserDefaults.shared.set(clientApplicationPermissions, forKey: "ClientApplicationPermissions")
		exit(0)
	default:
		fputs("The user denied the connection attempt from \(process.path) (\(pid)).\n", stderr)
		clientApplicationPermissions.append(["path":topLevelProcess.path, "policy": "deny"])
		UserDefaults.shared.set(clientApplicationPermissions, forKey: "ClientApplicationPermissions")
		exit(1)
	}
}
catch {
	// getting process path failed
	// cehck if it is a remote client
	if let remoteClientAddr = clientAddr, remoteClientAddr != "::1" && remoteClientAddr !=  "127.0.0.1" {
		for client in clientApplicationPermissions {
			if client["address"] as? String == remoteClientAddr {
				if let policy = client["policy"] as? String {
					if policy == "allow" {
						exit(0)
					} else {
						fputs("Connection attempt from \(remoteClientAddr) denied by Postgres.app settings.\n", stderr)
						exit(1)
					}
				}
			}
		}
		
		NSApplication.shared.setActivationPolicy(.accessory)
		NSApplication.shared.activate(ignoringOtherApps: true)

		let alert = NSAlert()

		alert.messageText = "A remote client is trying to connect to Postgres.app without using a password"
		alert.informativeText =
			"""
			Incoming connection from: \(remoteClientAddr)
			
			You can reset permissions later in Postgres.app settings.
			"""
		
		alert.addButton(withTitle: "OK")
		alert.addButton(withTitle: "Don't Allow")

		let result = alert.runModal()

		switch result {
		case .alertFirstButtonReturn:
			clientApplicationPermissions.append(["address":remoteClientAddr, "policy": "allow"])
			UserDefaults.shared.set(clientApplicationPermissions, forKey: "ClientApplicationPermissions")
			exit(0)
		default:
			fputs("The user denied the connection attempt from \(remoteClientAddr).\n", stderr)
			clientApplicationPermissions.append(["address":remoteClientAddr, "policy": "deny"])
			UserDefaults.shared.set(clientApplicationPermissions, forKey: "ClientApplicationPermissions")
			exit(1)
		}
	}
	else {
		// connection attempt from local client
		fputs("Postgres.app denied a connection from unknown local process\n", stderr);
		exit(1);
	}
}
