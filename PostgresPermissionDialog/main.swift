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
	fputs("Exit Status:\n", stderr)
	fputs("    0: Authentication should be allowed\n", stderr)
	fputs("    1: Authentication rejected by user in permission dialog\n", stderr)
	fputs("    2: Authentication rejected by user defaults\n", stderr)
	fputs("    3: Authentication denied because client process could not be identified\n", stderr)
	fputs("Any other exit status indicates that an error has occurred.\n", stderr)
	exit(4);
}

var clientApplicationPermissions: [[String: Any]]
clientApplicationPermissions = UserDefaults.shared.object(forKey: "ClientApplicationPermissions") as? [[String : Any]] ?? readClientPermissionsDirectly() ?? []

class HelpDelegate: NSObject, NSAlertDelegate {
    func alertShowHelp(_ alert: NSAlert) -> Bool {
        NSWorkspace.shared.open(URL(string:"https://postgresapp.com/l/app-permissions/")!)
    }
}

do {
	let process = try UnixProcessInfo(runningProcessWithPid: pid)
	let topLevelProcess = process.getTopLevelProcess()
	var topLevelProcessPath = topLevelProcess.path

	let selfInfo = try UnixProcessInfo(runningProcessWithPid: ProcessInfo.processInfo.processIdentifier)
	let selfContainingDirectory = (selfInfo.path as NSString).deletingLastPathComponent
	if (topLevelProcessPath.hasPrefix(selfContainingDirectory)) {
		exit(0)
	}
	
	if topLevelProcessPath.contains("AppTranslocation") {
		if let originalURL = SecTranslocateCreateOriginalPathForURL(URL(fileURLWithPath: topLevelProcessPath)) {
			topLevelProcessPath = originalURL.path
		}
	}
	
	// check user defaults
	var didFindMatch = false
	for client in clientApplicationPermissions {
		if let path = client["path"] as? String, path == topLevelProcessPath {
			didFindMatch = true
			if let policy = client["policy"] as? String {
				if policy == "allow" {
					exit(0)
				}
				else if policy == "deny" {
					UserDefaults.shared.set(Date(), forKey: "ClientApplicationPermissionLastDeniedDate")
					UserDefaults.shared.set("Connection attempt from \(topLevelProcess.name) denied by Postgres.app settings.", forKey: "ClientApplicationPermissionLastDeniedMessage")
					exit(2)
				}
			}
		}
	}
	if !didFindMatch {
		// record app without policy in case of timeout or crash
		clientApplicationPermissions.append(["path":topLevelProcessPath])
		UserDefaults.shared.set(clientApplicationPermissions, forKey: "ClientApplicationPermissions")
	}

	// We need to intercept the SIGABRT signal because NSApplication.shared calls abort() when no GUI session is available
	let oldHandler = signal(SIGABRT, { _ in
		// Exit code 4 tells the parent process that we failed to show a dialog
		_exit(4);
	})
	
	NSApplication.shared.setActivationPolicy(.accessory)
	NSApplication.shared.activate(ignoringOtherApps: true)

	// Restore the previous signal handler so we don't catch any unexpected errors
	signal(SIGABRT, oldHandler)
	
	let alert = NSAlert()
    let delegate = HelpDelegate()
    
	alert.messageText = "“\(topLevelProcess.name)” wants to connect to Postgres.app without using a password"
	alert.informativeText = "You can change permissions later in Postgres.app settings."
    alert.showsHelp = true
    alert.delegate = delegate
    

	alert.addButton(withTitle: "OK").keyEquivalent = ""
	alert.addButton(withTitle: "Don't Allow")

	let result = alert.runModal()

	switch result {
	case .alertFirstButtonReturn:
		clientApplicationPermissions.removeAll { $0["path"] as? String == topLevelProcessPath }
		clientApplicationPermissions.append(["path":topLevelProcessPath, "policy": "allow"])
		UserDefaults.shared.set(clientApplicationPermissions, forKey: "ClientApplicationPermissions")
		exit(0)
	default:
		clientApplicationPermissions.removeAll { $0["path"] as? String == topLevelProcessPath }
		clientApplicationPermissions.append(["path":topLevelProcessPath, "policy": "deny"])
		UserDefaults.shared.set(clientApplicationPermissions, forKey: "ClientApplicationPermissions")
		UserDefaults.shared.set(Date(), forKey: "ClientApplicationPermissionLastDeniedDate")
		UserDefaults.shared.set("The user denied the connection attempt from \(topLevelProcess.name).", forKey: "ClientApplicationPermissionLastDeniedMessage")
		exit(1)
	}
}
catch {
	// getting process path failed
	// cehck if it is a remote client
	if let remoteClientAddr = clientAddr, remoteClientAddr != "::1" && remoteClientAddr !=  "127.0.0.1" {
		var didFindMatch = false
		for client in clientApplicationPermissions {
			if client["address"] as? String == remoteClientAddr {
				didFindMatch = true
				if let policy = client["policy"] as? String {
					if policy == "allow" {
						exit(0)
					}
					else if policy == "deny" {
						UserDefaults.shared.set(Date(), forKey: "ClientApplicationPermissionLastDeniedDate")
						UserDefaults.shared.set("Connection attempt from \(remoteClientAddr) denied by Postgres.app settings.", forKey: "ClientApplicationPermissionLastDeniedMessage")
						exit(2)
					}
				}
			}
		}
		if !didFindMatch {
			// record app without policy in case of timeout or crash
			clientApplicationPermissions.append(["address":remoteClientAddr])
			UserDefaults.shared.set(clientApplicationPermissions, forKey: "ClientApplicationPermissions")
		}

		NSApplication.shared.setActivationPolicy(.accessory)
		NSApplication.shared.activate(ignoringOtherApps: true)

		let alert = NSAlert()
        let delegate = HelpDelegate()
        
		alert.messageText = "A remote client is trying to connect to Postgres.app without using a password"
		alert.informativeText =
			"""
			Incoming connection from: \(remoteClientAddr)
			
			You can change permissions later in Postgres.app settings.
			"""
		
		alert.addButton(withTitle: "OK").keyEquivalent = ""
		alert.addButton(withTitle: "Don't Allow")
        alert.showsHelp = true
        alert.delegate = delegate

		let result = alert.runModal()

		switch result {
		case .alertFirstButtonReturn:
			clientApplicationPermissions.removeAll { $0["address"] as? String == remoteClientAddr }
			clientApplicationPermissions.append(["address":remoteClientAddr, "policy": "allow"])
			UserDefaults.shared.set(clientApplicationPermissions, forKey: "ClientApplicationPermissions")
			exit(0)
		default:
			clientApplicationPermissions.removeAll { $0["address"] as? String == remoteClientAddr }
			clientApplicationPermissions.append(["address":remoteClientAddr, "policy": "deny"])
			UserDefaults.shared.set(clientApplicationPermissions, forKey: "ClientApplicationPermissions")
			UserDefaults.shared.set(Date(), forKey: "ClientApplicationPermissionLastDeniedDate")
			UserDefaults.shared.set("The user denied a connection attempt from \(remoteClientAddr).", forKey: "ClientApplicationPermissionLastDeniedMessage")
			exit(1)
		}
	}
	else {
		// connection attempt from local client
		UserDefaults.shared.set(Date(), forKey: "ClientApplicationPermissionLastDeniedDate")
		UserDefaults.shared.set("Postgres.app denied a connection from unknown local process", forKey: "ClientApplicationPermissionLastDeniedMessage")
		exit(3);
	}
}

func readClientPermissionsDirectly() -> [[String: Any]]? {
	// This is a workaround for an issue where UserDefaults fails
	// The issue happened when logging out -> the postgres process would continue running,
	// but the connection to the GUI session was lost. This caused all user defaults related APIs to return nil
	// As a workaround, we try to read preferences directly from disk
	// Related: https://github.com/PostgresApp/PostgresApp/issues/749
	let prefsurl = URL(fileURLWithPath: NSHomeDirectory()+"/Library/Preferences/com.postgresapp.Postgres2.plist")
	guard let prefsdata = try? Data(contentsOf: prefsurl) else {
		print("PostgresPermissionDialog: Could not read preferences from \(prefsurl.path)")
		return nil
	}
	guard let plist = try? PropertyListSerialization.propertyList(from: prefsdata, format: nil) as? NSDictionary else {
		print("PostgresPermissionDialog: Could not parse preferences file \(prefsurl.path)")
		return nil
	}
	guard let permissions = plist["ClientApplicationPermissions"] as? [[String: Any]] else {
		print("PostgresPermissionDialog: Key ClientApplicationPermissions not found in \(prefsurl.path)")
		return nil
	}
	return permissions
}
