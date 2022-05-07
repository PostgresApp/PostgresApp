//
//  Server.swift
//  Postgres
//
//  Created by Chris on 01/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class Server: NSObject {
	
	static let VersionsPath = "/Applications/Postgres.app/Contents/Versions"
	
	static let PropertyChangedNotification = Notification.Name("Server.PropertyChangedNotification")
	static let StatusChangedNotification = Notification.Name("Server.StatusChangedNotification")
	
	
	@objc enum ServerStatus: Int {
		case NoBinaries
		case PortInUse
		case DataDirInUse
		case DataDirEmpty
		case Running
		case Startable
		case StalePidFile
		case PidFileUnreadable
		case Unknown
	}
	
	enum ActionStatus {
		case Success
		case Failure(NSError)
        
        init(block: () throws -> () ) {
            do {
                try block()
                self = .Success
            } catch let error as NSError {
                self = .Failure(error)
            }
        }
	}
	
	
	@objc dynamic var name: String = "" {
		didSet {
			NotificationCenter.default.post(name: Server.PropertyChangedNotification, object: self)
		}
	}
    @objc var subtitle: String {
        var infos = [String]()
        infos.append("Port \(self.port)")
        if let v = self.dataDirectoryVersion { infos.append("v\(v)")}
        return infos.joined(separator: " – ")
    }
    @objc static var keyPathsForValuesAffectingSubtitle: Set<String> { ["port", "binPath", "serverStatus"] }

    
    
	@objc dynamic var port: UInt = 0 {
		didSet {
			NotificationCenter.default.post(name: Server.PropertyChangedNotification, object: self)
		}
	}
    @objc dynamic var binPath: String = ""
	@objc dynamic var varPath: String = ""
	@objc dynamic var startOnLogin: Bool = false {
		didSet {
			NotificationCenter.default.post(name: Server.PropertyChangedNotification, object: self)
		}
	}
	@objc dynamic var configFilePath: String {
		return varPath.appending("/postgresql.conf")
	}
	@objc dynamic var hbaFilePath: String {
		return varPath.appending("/pg_hba.conf")
	}
	@objc dynamic var logFilePath: String {
		return varPath.appending("/postgresql.log")
	}
	private var pidFilePath: String {
		return varPath.appending("/postmaster.pid")
	}
	private var pgVersionPath: String {
		return varPath.appending("/PG_VERSION")
	}
	private var configPlistPath: String {
		return varPath + "/postgresapp_config.plist"
	}
	
	var configPlist: [String: Any] {
		get {
			if let data = try? Data(contentsOf: URL(fileURLWithPath: configPlistPath)),
			   let plist = try? PropertyListSerialization.propertyList(from: data, format: nil),
			   let configPlist = plist as? [String:Any]
			{
				return configPlist
			} else {
				return [:]
			}
		}
		set {
			if let data = try? PropertyListSerialization.data(fromPropertyList: newValue, format: .xml, options: 0) {
				try? data.write(to: URL(fileURLWithPath: configPlistPath))
			}
		}
	}
	
	@objc dynamic private(set) var busy: Bool = false
	@objc dynamic private(set) var running: Bool = false
	@objc dynamic private(set) var serverStatus: ServerStatus = .Unknown
	@objc dynamic private(set) var databases: [Database] = []
	@objc dynamic var selectedDatabaseIndices = IndexSet()
	
	var firstSelectedDatabase: Database? {
		guard let firstIndex = selectedDatabaseIndices.first else { return nil }
		return databases[firstIndex]
	}
	
	var asPropertyList: [AnyHashable: Any] {
		var result: [AnyHashable: Any] = [:]
		result["name"] = self.name
		result["port"] = self.port
		result["binPath"] = self.binPath
		result["varPath"] = self.varPath
		result["startOnLogin"] = self.startOnLogin
		return result
	}
	
	
	init(name: String, version: String? = nil, port: UInt = 5432, varPath: String? = nil, startOnLogin: Bool = false) {
		super.init()
		let effectiveVersion = version ?? Bundle.main.object(forInfoDictionaryKey: "LatestStablePostgresVersion") as! String
		self.name = name
		self.port = port
		self.binPath = Server.VersionsPath.appendingFormat("/%@/bin", effectiveVersion)
		self.varPath = varPath ?? FileManager().applicationSupportDirectoryPath().appendingFormat("/var-%@", effectiveVersion)
		self.startOnLogin = startOnLogin
		updateServerStatus()
	}
	
	init?(propertyList: [AnyHashable: Any]) {
		guard let name = propertyList["name"] as? String,
		let port = propertyList["port"] as? UInt,
		let binPath = propertyList["binPath"] as? String,
		let varPath = propertyList["varPath"] as? String
		else {
			return nil
		}
		self.name = name
		self.port = port
		self.binPath = binPath
		self.varPath = varPath
		self.startOnLogin = propertyList["startOnLogin"] as? Bool ?? false
	}
	
	
	// MARK: Async handlers
	func start(_ completion: @escaping (ActionStatus) -> Void) {
		busy = true
		updateServerStatus()
		
		DispatchQueue.global().async {
			let statusResult: ActionStatus
			
			switch self.serverStatus {
			
			case .NoBinaries:
				var userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("Required PostgreSQL version not installed", comment: ""),
				]
				var recoverySuggestions = [String]()
				if let dataDirVersion = self.dataDirectoryVersion {
					recoverySuggestions.append(String(format: NSLocalizedString("The data directory was initialized with PostgreSQL %@.", comment: ""), dataDirVersion))
				}
				let versions = Self.availableBinaryVersions
				if !versions.isEmpty {
					recoverySuggestions.append(String(format: NSLocalizedString("This copy of Postgres.app includes the following PostgreSQL versions: %@.", comment: ""), versions.joined(separator: ", ")))
				}
				recoverySuggestions.append(NSLocalizedString("Please try downloading a different release of Postgres.app.", comment: ""))
				userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestions.joined(separator: "\n\n")
				statusResult = .Failure(NSError(domain: "com.postgresapp.Postgres2.server-status", code: 0, userInfo: userInfo))
				
			case .PortInUse:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("Port \(self.port) is already in use", comment: ""),
					NSLocalizedRecoverySuggestionErrorKey: "Usually this means that there is already a PostgreSQL server running on your Mac. If you want to run multiple servers simultaneously, use different ports."
				]
				statusResult = .Failure(NSError(domain: "com.postgresapp.Postgres2.server-status", code: 0, userInfo: userInfo))
				
			case .DataDirInUse:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("There is already a PostgreSQL server running in this data directory", comment: ""),
				]
				statusResult = .Failure(NSError(domain: "com.postgresapp.Postgres2.server-status", code: 0, userInfo: userInfo))
				
			case .DataDirEmpty:
                statusResult = ActionStatus {
                    if self.portInUse() {
                        let userInfo = [
                            NSLocalizedDescriptionKey: NSLocalizedString("Port \(self.port) is already in use", comment: ""),
                            NSLocalizedRecoverySuggestionErrorKey: "Usually this means that there is already a PostgreSQL server running on your Mac. If you want to run multiple servers simultaneously, use different ports."
                        ]
                        throw NSError(domain: "com.postgresapp.Postgres2.server-status", code: 0, userInfo: userInfo)
                    }
                    
                    try self.initDatabaseSync()
                    
                    try self.startSync()
                    
                    try self.createUserSync()
                    
                    try self.createUserDatabaseSync()
                }
			case .Running:
				statusResult = .Success
				
			case .Startable:
                statusResult = ActionStatus {
                    try self.startSync()
                }
				
			case .StalePidFile:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("The data directory contains an old postmaster.pid file", comment: ""),
					NSLocalizedRecoverySuggestionErrorKey: "The data directory contains a postmaster.pid file, which usually means that the server is already running. When the server crashes or is killed, you have to remove this file before you can restart the server. Make sure that the database process is definitely not running anymore, otherwise your data directory will be corrupted."
				]
				statusResult = .Failure(NSError(domain: "com.postgresapp.Postgres2.server-status", code: 0, userInfo: userInfo))
				
			case .PidFileUnreadable:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("The data directory contains an unreadable postmaster.pid file", comment: "")
				]
				statusResult = .Failure(NSError(domain: "com.postgresapp.Postgres2.server-status", code: 0, userInfo: userInfo))
				
			case .Unknown:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("Unknown server status", comment: "")
				]
				statusResult = .Failure(NSError(domain: "com.postgresapp.Postgres2.server-status", code: 0, userInfo: userInfo))
				
			}
			
			DispatchQueue.main.async {
				self.updateServerStatus()
				completion(statusResult)
				self.busy = false
			}
			
		}
	}
	
	
	/// Attempts to stop the server (in a background thread)
	/// - parameter completion: This closure will be called on the main thread when the server has stopped.
	func stop(_ completion: @escaping (ActionStatus) -> Void) {
		busy = true
		
		DispatchQueue.global().async {
            let stopRes = ActionStatus {
                try self.stopSync()
            }
			DispatchQueue.main.async {
				self.updateServerStatus()
				completion(stopRes)
				self.busy = false
			}
		}
	}
	
	var initDBOSVersion: String {
		if _initDBOSVersion == nil {
			checkInitdbOSVersion()
		}
		return _initDBOSVersion!
	}
	fileprivate var _initDBOSVersion: String?
	func checkInitdbOSVersion() {
		guard _initDBOSVersion == nil else { return }
		
		var currentConfigPlist = configPlist
		
		// try loading saved version
		if let osVersion = currentConfigPlist["initdb_macos_version"] as? String {
			_initDBOSVersion = osVersion
			return
		}
		
		// try loading previous guess
		if let osVersion = currentConfigPlist["initdb_macos_version_guessed"] as? String {
			_initDBOSVersion = osVersion
			return
		}
		
		//no previous guess, we need to make a guess now
		if let history = InstallHistory.local {
			if let pgVersionAttributes = try? FileManager().attributesOfItem(atPath: pgVersionPath) {
				if let creationDate = pgVersionAttributes[.creationDate] as? Date {
					let guessedVersion = history.macOSVersion(on: creationDate) ?? "0"
					_initDBOSVersion = guessedVersion
					currentConfigPlist["initdb_macos_version_guessed"] = guessedVersion
					configPlist	= currentConfigPlist
					return
				}
			}
		}
		
		_initDBOSVersion = "0"
	}
	
	/// Checks if the server is running.
	/// Must be called only from the main thread.
	func updateServerStatus() {
		checkInitdbOSVersion()
		
		if !FileManager.default.fileExists(atPath: binPath) {
			serverStatus = .NoBinaries
			running = false
			databases.removeAll()
			return
		}
		
		if !FileManager.default.fileExists(atPath: pgVersionPath) {
			serverStatus = .DataDirEmpty
			running = false
			databases.removeAll()
			return
		}
		
		if FileManager.default.fileExists(atPath: pidFilePath) {
			guard let pidFileContents = try? String(contentsOfFile: pidFilePath, encoding: .utf8) else {
				serverStatus = .PidFileUnreadable
				running = false
				databases.removeAll()
				return
			}
			
			let firstLine = pidFileContents.components(separatedBy: .newlines).first!
			guard let pid = Int32(firstLine) else {
				serverStatus = .PidFileUnreadable
				running = false
				databases.removeAll()
				return
			}
			
			var buffer = [CChar](repeating: 0, count: 1024)
			proc_pidpath(pid, &buffer, UInt32(buffer.count))
			let processPath = String(cString: buffer)
			
			if processPath == binPath.appending("/postgres") {
				serverStatus = .Running
				running = true
				databases.removeAll()
				loadDatabases()
				return
			}
			else if processPath.hasSuffix("postgres") || processPath.hasSuffix("postmaster") {
				serverStatus = .DataDirInUse
				running = false
				databases.removeAll()
				return
			}
			else if !processPath.isEmpty {
				serverStatus = .StalePidFile
				running = false
				databases.removeAll()
				return
			}
		}
		
		if portInUse() {
			serverStatus = .PortInUse
			running = false
			databases.removeAll()
			return
		}
		
		serverStatus = .Startable
		running = false
		databases.removeAll()
	}
	
	
	/// Checks if the port is in use by another process.
	private func portInUse() -> Bool {
		let sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)
		if sock <= 0 {
			return false
		}
		
		var listenAddress = sockaddr_in()
		listenAddress.sin_family = UInt8(AF_INET)
		listenAddress.sin_port = in_port_t(port).bigEndian
		listenAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
		listenAddress.sin_addr.s_addr = inet_addr("127.0.0.1")
		
		let bindRes = withUnsafePointer(to: &listenAddress) { (sockaddrPointer: UnsafePointer<sockaddr_in>) in
			sockaddrPointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPointer2 in
				Darwin.bind(sock, sockaddrPointer2, socklen_t(MemoryLayout<sockaddr_in>.stride))
			}
		}
		
		let bindErr = Darwin.errno
		close(sock)
		
		if bindRes == -1 && bindErr == EADDRINUSE {
			return true
		}
		
		return false
	}
	
	
	/// Loads the databases from the servers.
	private func loadDatabases() {
		databases.removeAll()
		
#if HAVE_LIBPQ
		let url = "postgresql://:\(port)"
		let connection = PQconnectdb(url.cString(using: .utf8))
		
		if PQstatus(connection) == CONNECTION_OK {
			let result = PQexec(connection, "SELECT datname FROM pg_database WHERE datallowconn ORDER BY LOWER(datname)")
			for i in 0..<PQntuples(result) {
				guard let value = PQgetvalue(result, i, 0) else { continue }
				let name = String(cString: value)
				databases.append(Database(name))
			}
			PQclear(result)
		}
		PQfinish(connection)
#endif
	}
	
	
	// MARK: Sync handlers
	func startSync() throws {
		let process = Process()
		let launchPath = binPath.appending("/pg_ctl")
		guard FileManager().fileExists(atPath: launchPath) else {
			let userInfo: [String: Any] = [
				NSLocalizedDescriptionKey: NSLocalizedString("The binaries for this PostgreSQL server were not found.", comment: ""),
			]
			throw NSError(domain: "com.postgresapp.Postgres2.pg_ctl", code: 0, userInfo: userInfo)
		}
		process.launchPath = launchPath
		process.arguments = [
			"start",
			"-D", varPath,
			"-w",
			"-l", logFilePath,
			"-o", String("-p \(port)"),
		]
		process.standardOutput = Pipe()
		let errorPipe = Pipe()
		process.standardError = errorPipe
        try process.launchAndCheckForRosetta()
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		process.waitUntilExit()
		
		guard process.terminationStatus == 0 else {
			let userInfo: [String: Any] = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not start PostgreSQL server.", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
				NSLocalizedRecoveryOptionsErrorKey: ["OK", "Open Server Log"],
				NSRecoveryAttempterErrorKey: ErrorRecoveryAttempter(recoveryAttempter: { (error, optionIndex) -> Bool in
					if optionIndex == 1 {
						NSWorkspace.shared.openFile(self.logFilePath, withApplication: "Console")
					}
					return true
				})
			]
			throw NSError(domain: "com.postgresapp.Postgres2.pg_ctl", code: 0, userInfo: userInfo)
		}
	}
	
	
	func stopSync() throws {
		let process = Process()
		process.launchPath = binPath.appending("/pg_ctl")
		process.arguments = [
			"stop",
			"-m", "f",
			"-D", varPath,
			"-w",
		]
		process.standardOutput = Pipe()
		let errorPipe = Pipe()
		process.standardError = errorPipe
        try process.launchAndCheckForRosetta()
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		process.waitUntilExit()
		
		guard process.terminationStatus == 0 else {
			let userInfo: [String: Any] = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not stop PostgreSQL server.", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
				NSLocalizedRecoveryOptionsErrorKey: ["OK", "Open Server Log"],
				NSRecoveryAttempterErrorKey: ErrorRecoveryAttempter(recoveryAttempter: { (error, optionIndex) -> Bool in
					if optionIndex == 1 {
						NSWorkspace.shared.openFile(self.logFilePath, withApplication: "Console")
					}
					return true
				})
			]
			throw NSError(domain: "com.postgresapp.Postgres2.pg_ctl", code: 0, userInfo: userInfo)
		}
	}
	
	
	private func initDatabaseSync() throws {
		let process = Process()
		process.launchPath = binPath.appending("/initdb")
		process.arguments = [
			"-D", varPath,
			"-U", "postgres",
			"--encoding=UTF-8",
			"--locale=en_US.UTF-8"
		]
		process.standardOutput = Pipe()
		let errorPipe = Pipe()
		process.standardError = errorPipe
        try process.launchAndCheckForRosetta()
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		process.waitUntilExit()
		
		guard process.terminationStatus == 0 else {
			let userInfo: [String: Any] = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not initialize database cluster.", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
				NSLocalizedRecoveryOptionsErrorKey: ["OK", "Open Server Log"],
				NSRecoveryAttempterErrorKey: ErrorRecoveryAttempter(recoveryAttempter: { (error, optionIndex) -> Bool in
					if optionIndex == 1 {
						NSWorkspace.shared.openFile(self.logFilePath, withApplication: "Console")
					}
					return true
				})
			]
			throw NSError(domain: "com.postgresapp.Postgres2.initdb", code: 0, userInfo: userInfo)
		}
		
		// record initdb version
		let osVersion = ProcessInfo.processInfo.macosDisplayVersion
		_initDBOSVersion = osVersion
		var currentConfigPlist = configPlist
		currentConfigPlist["initdb_macos_version"] = osVersion
		configPlist	= currentConfigPlist
	}
	
	
	private func createUserSync() throws {
		let process = Process()
		process.launchPath = binPath.appending("/createuser")
		process.arguments = [
			"-U", "postgres",
			"-p", String(port),
			"--superuser",
			NSUserName()
		]
		process.standardOutput = Pipe()
		let errorPipe = Pipe()
		process.standardError = errorPipe
        try process.launchAndCheckForRosetta()
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		process.waitUntilExit()
		
		guard process.terminationStatus == 0 else {
			let userInfo: [String: Any] = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not create default user.", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
				NSLocalizedRecoveryOptionsErrorKey: ["OK", "Open Server Log"],
				NSRecoveryAttempterErrorKey: ErrorRecoveryAttempter(recoveryAttempter: { (error, optionIndex) -> Bool in
					if optionIndex == 1 {
						NSWorkspace.shared.openFile(self.logFilePath, withApplication: "Console")
					}
					return true
				})
			]
			throw NSError(domain: "com.postgresapp.Postgres2.createuser", code: 0, userInfo: userInfo)
		}
	}
	
	
	private func createUserDatabaseSync() throws {
		let process = Process()
		process.launchPath = binPath.appending("/createdb")
		process.arguments = [
			"-p", String(port),
			NSUserName()
		]
		process.standardOutput = Pipe()
		let errorPipe = Pipe()
		process.standardError = errorPipe
        try process.launchAndCheckForRosetta()
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		process.waitUntilExit()
		
		guard process.terminationStatus == 0 else {
			let userInfo: [String: Any] = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not create user database.", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
				NSLocalizedRecoveryOptionsErrorKey: ["OK", "Open Server Log"],
				NSRecoveryAttempterErrorKey: ErrorRecoveryAttempter(recoveryAttempter: { (error, optionIndex) -> Bool in
					if optionIndex == 1 {
						NSWorkspace.shared.openFile(self.logFilePath, withApplication: "Console")
					}
					return true
				})
			]
			throw NSError(domain: "com.postgresapp.Postgres2.createdb", code: 0, userInfo: userInfo)
		}
	}
	
	public static var availableBinaryVersions: [String] {
		guard let versionsPathEnum = FileManager().enumerator(at: URL(fileURLWithPath: Server.VersionsPath), includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]) else { return [] }
		var versions = [String]()
		while let itemURL = versionsPathEnum.nextObject() as? URL {
			do {
				let resourceValues = try itemURL.resourceValues(forKeys: [.isDirectoryKey])
				guard resourceValues.isDirectory == true else { continue }
			} catch { continue }
			let folderName = itemURL.lastPathComponent
			versions.append(folderName)
		}
		versions.sort { (a, b) -> Bool in
			return a.compare(b, options:[.numeric], range: a.startIndex ..< a.endIndex, locale: nil) == .orderedAscending
		}
		return versions
	}
    
    var dataDirectoryVersion: String? {
        do {
            let v = try String(contentsOfFile: pgVersionPath)
            return v.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        catch {
            return nil
        }
    }
}

class Database: NSObject {
	@objc dynamic var name: String = ""
	
	init(_ name: String) {
		super.init()
		self.name = name
	}
}

