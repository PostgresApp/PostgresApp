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
		case .unknown:
			return NSImage(named: .statusNone)
		case .running:
			return NSImage(named: NSImage.Name("icon-running"))
		default:
			return NSImage(named:NSImage.Name("icon-stopped"))
		}
	}
}

class ServerStatusTemplateImageTransformer: ValueTransformer {
	override func transformedValue(_ value: Any?) -> Any? {
		guard let intStatus = value as? Int, let status = Server.ServerStatus(rawValue: intStatus) else { return nil }
		switch status {
		case .unknown:
			return NSImage(named: .statusNone)
		case .running:
			return NSImage(named: NSImage.Name("icon-running-template"))
		default:
			return NSImage(named:NSImage.Name("icon-stopped-template"))
		}
	}
}

class ServerStatusButtonTitleTransformer: ValueTransformer {
	override func transformedValue(_ value: Any?) -> Any? {
		guard let intStatus = value as? Int, let status = Server.ServerStatus(rawValue: intStatus) else { return nil }
		switch status {
		case .dataDirEmpty:
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
		case .dataDirEmpty:
			return "Initialize"
		case .running:
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
		case .noBinaries:
			return "Binaries not found"
		case .dataDirEmpty:
			return "Empty data directory"
		case .dataDirInUse:
			return "Data directory in use"
		case .stalePidFile:
			return "Stale postmaster.pid file"
		case .pidFileUnreadable:
			return "Unreadable postmaster.pid file"
		case .portInUse:
			return "Port in use"
		case .startable:
			return "Not running"
		case .running:
			return "Running"
		case .unknown:
			return "Unknown server status"
		}
	}
}
