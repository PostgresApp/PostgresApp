//
//  main.swift
//  PostgresPermissionDialog
//
//  Created by Jakob Egger on 22.05.23.
//  Copyright © 2023 postgresapp. All rights reserved.
//

import AppKit

NSApplication.shared.setActivationPolicy(.accessory)
NSApplication.shared.activate(ignoringOtherApps: true)

let alert = NSAlert()

var args = CommandLine.arguments
var pid: pid_t?
while let arg = args.first {
	args.removeFirst()
	if arg == "--pid" {
		pid = pid_t(args.removeFirst())
	}
}

guard let pid else {
	fputs("Usage: \(CommandLine.arguments.first ?? "PostgresPermissionDialog") --pid 12345\n", stderr)
	exit(2);
}

let process = try UnixProcessInfo(runningProcessWithPid: pid)
let topLevelProcess = process.getTopLevelProcess()

// check user defaults

UserDefaults.shared.object(forKey: "ClientApplicationPermissions")


alert.messageText = "“\(topLevelProcess.name)” wants to connect to Postgres.app"

alert.icon = topLevelProcess.icon

let rememberCheckbox = NSButton(checkboxWithTitle: "Remember my choice", target: nil, action: nil)

alert.accessoryView = rememberCheckbox

alert.addButton(withTitle: "Allow")
alert.addButton(withTitle: "Deny")

let result = alert.runModal()

switch result {
case .alertFirstButtonReturn:
	exit(0)
default:
	fputs("The user denied the connection attempt from \(process.path) (\(pid)).\n", stderr)
	exit(1)
}
