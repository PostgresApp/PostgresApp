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
while let arg = args.first {
	args.removeFirst()
	if arg == "--client-pid" {
		pid = pid_t(args.removeFirst())
	}
}

guard let pid else {
	fputs("Usage: \(CommandLine.arguments.first ?? "PostgresPermissionDialog") --client-pid 12345\n", stderr)
	exit(2);
}

let process = try UnixProcessInfo(runningProcessWithPid: pid)
let topLevelProcess = process.getTopLevelProcess()

// check user defaults

var clientApplicationPermissions: [[String: Any]]

clientApplicationPermissions = UserDefaults.shared.object(forKey: "ClientApplicationPermissions") as? [[String : Any]] ?? []

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

alert.messageText = "“\(topLevelProcess.name)” wants to connect to Postgres.app"
alert.informativeText = "You can change your selection later in Postgres.app Settings."

alert.icon = topLevelProcess.icon

alert.addButton(withTitle: "Allow")
alert.addButton(withTitle: "Deny")

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
