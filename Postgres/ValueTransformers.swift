//
//  ValueTransformers.swift
//  Postgres
//
//  Created by Chris on 17/10/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class ServerStatusImageTransformer: ValueTransformer {
	override func transformedValue(_ value: Any?) -> Any? {
		guard let intStatus = value as? Int, let status = Server.ServerStatus(rawValue: intStatus) else { return nil }
		switch status {
		case .Unknown:
			return NSImage(imageLiteralResourceName: NSImageNameStatusNone)
		case .Running:
			return NSImage(named: "icon-running")
		default:
			return NSImage(named:"icon-stopped")
		}
	}
}

class ServerStatusTemplateImageTransformer: ValueTransformer {
	override func transformedValue(_ value: Any?) -> Any? {
		guard let intStatus = value as? Int, let status = Server.ServerStatus(rawValue: intStatus) else { return nil }
		switch status {
		case .Unknown:
			return NSImage(imageLiteralResourceName: NSImageNameStatusNone)
		case .Running:
			return NSImage(named: "icon-running-template")
		default:
			return NSImage(named:"icon-stopped-template")
		}
	}
}

class ServerStatusButtonTitleTransformer: ValueTransformer {
	override func transformedValue(_ value: Any?) -> Any? {
		guard let intStatus = value as? Int, let status = Server.ServerStatus(rawValue: intStatus) else { return nil }
		switch status {
		case .DataDirEmpty:
			return "Initialize"
		default:
			return "Start"
		}
	}
}

class ServerStatusMenuItemButtonTitleTransformer: ValueTransformer {
	override func transformedValue(_ value: Any?) -> Any? {
		guard let intStatus = value as? Int, let status = Server.ServerStatus(rawValue: intStatus) else { return nil }
		switch status {
		case .DataDirEmpty:
			return "Initialize"
		case .Running:
			return "Stop"
		default:
			return "Start"
		}
	}
}

class ServerStatusStatusMessageTransformer: ValueTransformer {
	override func transformedValue(_ value: Any?) -> Any? {
		guard let intStatus = value as? Int, let status = Server.ServerStatus(rawValue: intStatus) else { return nil }
		switch status {
		case .NoBinaries:
			return "Binaries not found"
		case .DataDirEmpty:
			return "Empty data directory"
		case .DataDirInUse:
			return "Data directory in use"
		case .StalePidFile:
			return "Stale postmaster.pid file"
		case .PidFileUnreadable:
			return "Unreadable postmaster.pid file"
		case .PortInUse:
			return "Port in use"
		case .Startable:
			return "Not running"
		case .Running:
			return "Running"
		case .Unknown:
			return "Unknown server status"
		}
	}
}
