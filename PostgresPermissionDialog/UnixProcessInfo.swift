//
//  UnixProcessInfo.swift
//  IPCS
//
//  Created by Jakob Egger on 11.02.22.
//

import Foundation
import AppKit

struct UnixProcessInfo {
	let pid: pid_t
	let path: String

	var name: String {
		String(path.split(separator: "/").last ?? "")
	}

	init(runningProcessWithPid pid: pid_t) throws {
		self.pid = pid
		var path = [UInt8](repeating: 0, count: Int(PROC_PIDPATHINFO_SIZE))
		let status = proc_pidpath(pid, &path, UInt32(path.count))
		if status > 0 {
			self.path = String(cString: path)
		} else {
			let errno_stored = errno
			let errorDescription = "proc_pidpath(\(pid)): " + String(cString:strerror(errno_stored)!)
			throw NSError(domain: "com.postgresapp.PostgresPermissionDialog", code: Int(errno_stored), userInfo: [NSLocalizedDescriptionKey: errorDescription])
		}
	}
	
	var icon: NSImage? {
		var pathComponents = path.components(separatedBy: "/")
		while let last = pathComponents.last {
			if last.hasSuffix(".app") { break }
			pathComponents.removeLast()
		}
		let appPath = pathComponents.joined(separator: "/")
		return NSWorkspace.shared.icon(forFile: appPath)
	}
	
	func bsdshortinfo() throws -> proc_bsdshortinfo {
		var shortinfo = proc_bsdshortinfo()
		let status = proc_pidinfo(pid_t(pid), PROC_PIDT_SHORTBSDINFO, 0, &shortinfo, Int32(MemoryLayout.size(ofValue: shortinfo)))
		guard status > 0 else {
			let errno_stored = errno
			let errorDescription = "proc_pidinfo(\(pid)): " + String(cString:strerror(errno_stored)!)
			throw NSError(domain: "com.postgresapp.PostgresPermissionDialog", code: Int(errno_stored), userInfo: [NSLocalizedDescriptionKey: errorDescription])
		}
		return shortinfo
	}
	
	func getParent() throws -> UnixProcessInfo {
		let shortinfo = try bsdshortinfo()
		let ppid = pid_t(shortinfo.pbsi_ppid)
		return try UnixProcessInfo(runningProcessWithPid: ppid)
	}
	
	func getTopLevelProcess() -> UnixProcessInfo {
		var process = self;
		while let parent = try? process.getParent() {
			if parent.pid <= 1 { break }
			process = parent
		}
		return process
	}
}
