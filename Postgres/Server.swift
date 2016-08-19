//
//  Server.swift
//  Postgres
//
//  Created by Chris on 01/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa



class Server: NSObject, NSCoding {
	
	static let changedNotification = NSNotification.Name("ServerDidChange")
	
	enum ServerStatus {
		case NoBinaries
		case PortInUse
		case DataDirInUse
		case DataDirIncompatible
		case DataDirEmpty
		case Running
		case Startable
		case StalePidFile
		case Unknown
	}
	
	enum ActionStatus {
		case Success
		case Failure(NSError)
	}
	
	
	dynamic var name: String = "" {
		didSet {
			NotificationCenter.default().post(name: Server.changedNotification, object: self)
		}
	}
	dynamic var version: String = ""
	dynamic var port: UInt = 0 {
		didSet {
			NotificationCenter.default().post(name: Server.changedNotification, object: self)
		}
	}
	dynamic var binPath: String = ""
	dynamic var varPath: String = ""
	dynamic var startAtLogin: Bool = false {
		didSet {
			NotificationCenter.default().post(name: Server.changedNotification, object: self)
		}
	}
	
	dynamic var configFilePath: String {
		return varPath.appending("/postgresql.conf")
	}
	dynamic var hbaFilePath: String {
		return varPath.appending("/pg_hba.conf")
	}
	dynamic var logFilePath: String {
		return varPath.appending("/postgresql.log")
	}
	
	dynamic private(set) var busy: Bool = false
	dynamic private(set) var running: Bool = false
	dynamic private(set) var statusMessage: String = ""
	dynamic private(set) var statusMessageExtended: String = ""
	dynamic private(set) var databases: [Database] = []
	
	private(set) var serverStatus: ServerStatus = .Unknown
	
	
	convenience init(name: String, version: String? = nil, port: UInt = 5432, varPath: String? = nil) {
		self.init()
		
		self.name = name
		self.version = version ?? Bundle.main().objectForInfoDictionaryKey("LatestStablePostgresVersion") as! String
		self.port = port
		self.binPath = AppDelegate.PG_APP_PATH.appendingFormat("/Contents/Versions/%@/bin", self.version)
		self.varPath = varPath ?? ""
		
		if self.varPath == "" {
			let path = FileManager().applicationSupportDirectoryPath()
			self.varPath = path.appending("/var-\(self.version)")
		}
		
		updateServerStatus()
		
		// TODO: read port from postgresql.conf
	}
	
	required convenience init(coder aDecoder: NSCoder) {
		self.init()
		
		guard let name = aDecoder.decodeObject(forKey: "name") as? String else { return }
		guard let version = aDecoder.decodeObject(forKey: "version") as? String else { return }
		guard let port = aDecoder.decodeObject(forKey: "port") as? UInt else { return }
		guard let varPath = aDecoder.decodeObject(forKey: "varPath") as? String else { return }
		let startAtLogin = aDecoder.decodeBool(forKey: "startAtLogin")
		
		self.name = name
		self.version = version
		self.port = port
		self.binPath = AppDelegate.PG_APP_PATH.appendingFormat("/Contents/Versions/%@/bin", version)
		self.varPath = varPath
		self.startAtLogin = startAtLogin
	}
	
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(name, forKey: "name")
		aCoder.encode(version, forKey: "version")
		aCoder.encode(UInt(port), forKey: "port")
		aCoder.encode(binPath, forKey: "binPath")
		aCoder.encode(varPath, forKey: "varPath")
		aCoder.encode(startAtLogin, forKey: "startAtLogin")
	}
	
	
	
	// MARK: Async handlers
	func start(closure: (ActionStatus) -> Void) {
		busy = true
		
		DispatchQueue.global().async {
			
			DispatchQueue.main.sync {
				self.updateServerStatus()
			}
			
			switch self.serverStatus {
			
			case .NoBinaries:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("The binaries for this PostgreSQL server were not found", comment: ""),
					NSLocalizedRecoverySuggestionErrorKey: "Create a new Server and try again."
				]
				let error = NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo)
				DispatchQueue.main.async {
					closure(.Failure(error))
				}
				
			case .PortInUse:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("Port \(self.port) is already in use", comment: ""),
					NSLocalizedRecoverySuggestionErrorKey: "Usually this means that there is already a PostgreSQL server running on your Mac. If you want to run multiple servers simultaneously, use different ports."
				]
				let error = NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo)
				DispatchQueue.main.async {
					closure(.Failure(error))
				}
				
			case .DataDirInUse:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("There is already a PostgreSQL server running in this data directory", comment: ""),
				]
				let error = NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo)
				DispatchQueue.main.async {
					closure(.Failure(error))
				}
				
			case .DataDirIncompatible:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("The data directory is not compatible with this version of PostgreSQL server.", comment: ""),
					NSLocalizedRecoverySuggestionErrorKey: "Please create a new Server."
				]
				let error = NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo)
				DispatchQueue.main.async {
					closure(.Failure(error))
				}
				
			case .DataDirEmpty:
				let initResult = self.initDatabaseSync()
				if case .Failure = initResult {
					DispatchQueue.main.async {
						closure(initResult)
					}
				}
				
				let startResult = self.startSync()
				if case .Failure = startResult {
					DispatchQueue.main.async {
						closure(startResult)
					}
				}
				
				let createUserResult = self.createUserSync()
				if case .Failure = createUserResult {
					DispatchQueue.main.async {
						closure(createUserResult)
					}
				}
				
				let createDBResult = self.createUserDatabaseSync()
				if case .Failure = createDBResult {
					DispatchQueue.main.async {
						closure(createDBResult)
					}
				}
				
				DispatchQueue.main.async {
					closure(.Success)
				}
				
			case .Running:
				DispatchQueue.main.async {
					closure(.Success)
				}
				
			case .Startable:
				let startRes = self.startSync()
				DispatchQueue.main.async {
					closure(startRes)
				}
				
			case .StalePidFile:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("The data directory contains an old postmaster.pid file", comment: ""),
					NSLocalizedRecoverySuggestionErrorKey: "The data directory contains a postmaster.pid file, which usually means that the server is already running. When the server crashes or is killed, you have to remove this file before you can restart the server. Make sure that the database process is definitely not runnnig anymore, otherwise your data directory will be corrupted."
				]
				let error = NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo)
				DispatchQueue.main.async {
					closure(.Failure(error))
				}
				
			case .Unknown:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("Unknown server status", comment: ""),
					NSLocalizedRecoverySuggestionErrorKey: ""
				]
				let error = NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo)
				DispatchQueue.main.async {
					closure(.Failure(error))
				}
				
			}
			
			DispatchQueue.main.async {
				self.updateServerStatus()
				self.busy = false
			}
			
		}
	}
	
	/// Attempts to stop the server (in a background thread)
	/// - parameter closure: This block will be called on the main thread when the server has stopped.
	func stop(closure: (ActionStatus) -> Void) {
		busy = true
		
		DispatchQueue.global().async {
			let stopRes = self.stopSync()
			DispatchQueue.main.async {
				closure(stopRes)
				self.busy = false
			}
		}
	}
	
	/// Checks if the server is running.
	/// Must be called only from the main thread.
	func updateServerStatus() {
		if !FileManager.default().fileExists(atPath: binPath) {
			running = false
			serverStatus = .NoBinaries
			statusMessage = "No binaries found"
			databases.removeAll()
			return
		}
		
		let pgVersionPath = varPath.appending("/PG_VERSION")
		
		if !FileManager.default().fileExists(atPath: pgVersionPath) {
			running = false
			serverStatus = .DataDirEmpty
			statusMessage = "Click ‘Start’ to initialize the server"
			databases.removeAll()
			return
		}
		
		do {
			let fileContents = try String(contentsOfFile: pgVersionPath)
			if version != fileContents.substring(to: fileContents.index(before: fileContents.endIndex)) {
				running = false
				serverStatus = .DataDirIncompatible
				statusMessage = "Database directory incompatible"
				databases.removeAll()
				return
			}
		} catch {
			running = false
			serverStatus = .Unknown
			statusMessage = "Could not determine data directory version"
			databases.removeAll()
			return
		}
		
		
		let pidFilePath = varPath.appending("/postmaster.pid")
		if FileManager.default().fileExists(atPath: pidFilePath) {
			guard let pidFileContents = try? String(contentsOfFile: pidFilePath, encoding: .utf8) else {
				running = false
				serverStatus = .Unknown
				statusMessage = "Could not read PID file"
				databases.removeAll()
				return
			}
			
			let firstLine = pidFileContents.components(separatedBy: .newlines).first!
			guard let pid = Int32(firstLine) else {
				running = false
				serverStatus = .Unknown
				statusMessage = "First line of PID file is not an integer"
				databases.removeAll()
				return
			}
			
			var buffer = [CChar](repeating: 0, count: 1024)
			proc_pidpath(pid, &buffer, UInt32(buffer.count))
			let processPath = String(cString: buffer)
			
			if processPath == binPath.appending("/postgres") {
				running = true
				serverStatus = .Running
				statusMessage = "PostgreSQL \(self.version) - Running on port \(self.port)"
				databases.removeAll()
				loadDatabases()
				return
			}
			else if processPath.hasSuffix("postgres") || processPath.hasSuffix("postmaster") {
				running = false
				serverStatus = .DataDirInUse
				statusMessage = "The data directory is in use by another server"
				databases.removeAll()
				return
			}
			else if !processPath.isEmpty {
				running = false
				serverStatus = .StalePidFile
				statusMessage = "Old postmaster.pid file detected"
				databases.removeAll()
				return
			}
		}
		
		if portInUse() {
			running = false
			serverStatus = .PortInUse
			statusMessage = "Port in use by another process"
			databases.removeAll()
			return
		} else {
			running = false
			serverStatus = .Startable
			statusMessage = "Not running"
			databases.removeAll()
			return
		}
		
	}
	
	
	func loadDatabases() {
		databases.removeAll()
		
		let url = "postgresql://:\(port)"
		let connection = PQconnectdb(url.cString(using: .utf8))
		
		if PQstatus(connection) == CONNECTION_OK {
			let result = PQexec(connection, "SELECT datname FROM pg_database WHERE datallowconn ORDER BY LOWER(datname)")
			for i in 0..<PQntuples(result) {
				guard let value = PQgetvalue(result, i, 0) else { continue }
				let name = String(cString: value)
				databases.append(Database(name))
			}
			PQfinish(connection)
		}
	}
	
	
	private func portInUse() -> Bool {
		let sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)
		if sock <= 0 {
			return false
		}
		
		var listenAddress = sockaddr_in()
		listenAddress.sin_family = UInt8(AF_INET)
		listenAddress.sin_port = in_port_t(self.port).bigEndian
		listenAddress.sin_len = UInt8(sizeofValue(listenAddress))
		listenAddress.sin_addr.s_addr = inet_addr("127.0.0.1")
		
		func make_sockaddr(_ p: UnsafePointer<sockaddr_in>) -> UnsafePointer<sockaddr> { return UnsafePointer<sockaddr>(p) }
		
		let bindRes = Darwin.bind(sock, make_sockaddr(&listenAddress), socklen_t(sizeofValue(listenAddress)))
		let saved_errno = errno
		
		close(sock)
		
		if bindRes == -1 && saved_errno == EADDRINUSE {
			return true
		}
		
		return false
	}
	
	
	// MARK: Sync handlers
	private func startSync() -> ActionStatus {
		let task = Task()
		task.launchPath = binPath.appending("/pg_ctl")
		task.arguments = [
			"start",
			"-D", varPath,
			"-w",
			"-l", logFilePath,
			"-o", String("-p \(port)"),
		]
		task.standardOutput = Pipe()
		let errorPipe = Pipe()
		task.standardError = errorPipe
		task.launch()
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		task.waitUntilExit()
		
		if task.terminationStatus == 0 {
			DispatchQueue.main.sync {
				updateServerStatus()
			}
			return .Success
		} else {
			let userInfo = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not start PostgreSQL server.", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
				NSLocalizedRecoveryOptionsErrorKey: ["OK", "Open Server Log"],
				NSRecoveryAttempterErrorKey: ErrorRecoveryAttempter(recoveryAttempter: { (error, optionIndex) -> Bool in
					if optionIndex == 1 {
						NSWorkspace.shared().openFile(self.logFilePath, withApplication: "Console")
					}
					return true
				}),
				]
			let error = NSError(domain: "com.postgresapp.Postgres.pg_ctl", code: Int(task.terminationStatus), userInfo: userInfo)
			return .Failure(error)
		}
	}
	
	
	private func stopSync() -> ActionStatus {
		let task = Task()
		task.launchPath = binPath.appending("/pg_ctl")
		task.arguments = [
			"stop",
			"-m", "f",
			"-D", varPath,
			"-w",
		]
		task.standardOutput = Pipe()
		let errorPipe = Pipe()
		task.standardError = errorPipe
		task.launch()
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		task.waitUntilExit()
		
		if task.terminationStatus == 0 {
			DispatchQueue.main.sync {
				updateServerStatus()
			}
			return .Success
		} else {
			let userInfo = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not stop PostgreSQL server.", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
				NSLocalizedRecoveryOptionsErrorKey: ["OK", "Open Server Log"],
				NSRecoveryAttempterErrorKey: ErrorRecoveryAttempter(recoveryAttempter: { (error, optionIndex) -> Bool in
					if optionIndex == 1 {
						NSWorkspace.shared().openFile(self.logFilePath, withApplication: "Console")
					}
					return true
				})
			]
			let error = NSError(domain: "com.postgresapp.Postgres.pg_ctl", code: Int(task.terminationStatus), userInfo: userInfo)
			return .Failure(error)
		}
	}
	
	
	private func initDatabaseSync() -> ActionStatus {
		let task = Task()
		task.launchPath = binPath.appending("/initdb")
		task.arguments = [
			"-D", varPath,
			"-U", "postgres",
			"--encoding=UTF-8",
			"--locale=en_US.UTF-8"
		]
		task.standardOutput = Pipe()
		let errorPipe = Pipe()
		task.standardError = errorPipe
		task.launch()
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		task.waitUntilExit()
		
		if task.terminationStatus == 0 {
			return .Success
		} else {
			let userInfo = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not initialize database cluster.", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
				NSLocalizedRecoveryOptionsErrorKey: ["OK", "Open Server Log"],
				NSRecoveryAttempterErrorKey: ErrorRecoveryAttempter(recoveryAttempter: { (error, optionIndex) -> Bool in
					if optionIndex == 1 {
						NSWorkspace.shared().openFile(self.logFilePath, withApplication: "Console")
					}
					return true
				})
			]
			let error = NSError(domain: "com.postgresapp.Postgres.initdb", code: Int(task.terminationStatus), userInfo: userInfo)
			return .Failure(error)
		}
	}
	
	
	private func createUserSync() -> ActionStatus {
		let task = Task()
		task.launchPath = binPath.appending("/createuser")
		task.arguments = [
			"-U", "postgres",
			"-p", String(port),
			"--superuser",
			NSUserName()
		]
		task.standardOutput = Pipe()
		let errorPipe = Pipe()
		task.standardError = errorPipe
		task.launch()
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		task.waitUntilExit()
		
		if task.terminationStatus == 0 {
			return .Success
		} else {
			let userInfo = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not create default user.", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
				NSLocalizedRecoveryOptionsErrorKey: ["OK", "Open Server Log"],
				NSRecoveryAttempterErrorKey: ErrorRecoveryAttempter(recoveryAttempter: { (error, optionIndex) -> Bool in
					if optionIndex == 1 {
						NSWorkspace.shared().openFile(self.logFilePath, withApplication: "Console")
					}
					return true
				})
			]
			let error = NSError(domain: "com.postgresapp.Postgres.createuser", code: Int(task.terminationStatus), userInfo: userInfo)
			return .Failure(error)
		}
	}
	
	
	private func createUserDatabaseSync() -> ActionStatus {
		let task = Task()
		task.launchPath = binPath.appending("/createdb")
		task.arguments = [
			"-p", String(port),
			NSUserName()
		]
		task.standardOutput = Pipe()
		let errorPipe = Pipe()
		task.standardError = errorPipe
		task.launch()
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		task.waitUntilExit()
		
		if task.terminationStatus == 0 {
			return .Success
		} else {
			let userInfo = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not create user database.", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
				NSLocalizedRecoveryOptionsErrorKey: ["OK", "Open Server Log"],
				NSRecoveryAttempterErrorKey: ErrorRecoveryAttempter(recoveryAttempter: { (error, optionIndex) -> Bool in
					if optionIndex == 1 {
						NSWorkspace.shared().openFile(self.logFilePath, withApplication: "Console")
					}
					return true
				})
			]
			let error = NSError(domain: "com.postgresapp.Postgres.createdb", code: Int(task.terminationStatus), userInfo: userInfo)
			return .Failure(error)
		}
	}
	
}



class Database: NSObject {
	dynamic var name: String = ""
	
	dynamic var icon: NSImage {
		
		let icon = NSImage(size: NSSize(width: 64, height: 63), flipped: false) { (dstRect) -> Bool in
			let baseColor = NSColor(calibratedRed: 0.714, green: 0.823, blue: 0.873, alpha: 1)
			let frameColor = baseColor.shadow(withLevel: 0.4)
			let fillColor = baseColor.highlight(withLevel: 0.7)
			
			frameColor?.setStroke()
			fillColor?.setFill()
			
			let lineWidth = CGFloat(1.0)
			
			for i in 0...3 {
				
				var y = lineWidth*0.5
				if i > 0 {
					y += (63-lineWidth-8) / 3 * CGFloat(i)
				}
				
				let oval = NSBezierPath(ovalIn: NSRect(x: lineWidth*0.5, y: y, width: 64-lineWidth, height: 8.0))
				
				oval.lineWidth = lineWidth
				oval.stroke()
				oval.fill()
				
				if i < 3 {
					var y1 = 4+lineWidth*0.5
					if i > 0 {
						y1 += (63-lineWidth-8) / 3 * CGFloat(i)
						
					}
					
					NSRectFillUsingOperation(NSRect(x: lineWidth*0.5, y: y1, width: 64-lineWidth, height: 16.0), NSCompositeCopy)
				}
			}
			
			frameColor?.setFill()
			NSRectFillUsingOperation(NSRect(x: 0, y: 4+lineWidth*0.5, width: lineWidth, height: 3*(63-lineWidth-8)/3), NSCompositeCopy)
			NSRectFillUsingOperation(NSRect(x: 64-lineWidth, y: 4+lineWidth*0.5, width: lineWidth, height: 3*(63-lineWidth-8)/3), NSCompositeCopy)
			
			return true
		}
		
		return icon
	}
	
	
	init(_ name: String) {
		super.init()
		self.name = name
	}
	
}

