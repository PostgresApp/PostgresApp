//
//  Server.swift
//  Postgres
//
//  Created by Chris on 01/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa
import CommonCrypto

class Server: NSObject {
		
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
    @objc dynamic var binPath: String = "" {
        didSet {
            NotificationCenter.default.post(name: Server.PropertyChangedNotification, object: self)
        }
    }
    var effectiveBinPath: String?
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
	@objc dynamic private(set) var serverWarning: String? = nil
	@objc dynamic private(set) var serverWarningButtonTitle: String? = nil
	@objc dynamic private(set) var serverWarningMessage: String? = nil
	@objc dynamic private(set) var serverWarningInformativeText: String? = nil
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
	
	
	init(name: String, binPath: String, port: UInt = 5432, varPath: String, startOnLogin: Bool = false) {
		super.init()
		self.name = name
		self.port = port
		self.binPath = binPath
		self.varPath = varPath
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
        
        if let effectiveBinPath = effectiveBinPath, binPath != effectiveBinPath {
            binPath = effectiveBinPath
        }
		
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
#if IS_MAIN_APP
				let versions = BinaryManager.shared.findAvailableBinaries().map { $0.version }
				if !versions.isEmpty {
					recoverySuggestions.append(String(format: NSLocalizedString("This copy of Postgres.app includes the following PostgreSQL versions: %@.", comment: ""), versions.joined(separator: ", ")))
				}
#endif
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
	
	// This function checks if the macOS version was recorded when doing initdb
	// If not, it tries to guess by comparing the creation date of pg_version to the list of macOS versions in InstallHistory.plist
	// This method is designed to be called only once, when first running a new version of Postgres.app
	func checkInitdbOSVersion() {
		var currentConfigPlist = configPlist
		
		// check if there is already a macos version stored
		if  currentConfigPlist["initdb_macos_version"] is String || currentConfigPlist["initdb_macos_version_guessed"] is String {
			return
		}
		
		//no previous guess, we need to make a guess now
		if let history = InstallHistory.local {
			if let pgVersionAttributes = try? FileManager().attributesOfItem(atPath: pgVersionPath) {
				if let creationDate = pgVersionAttributes[.creationDate] as? Date {
					let guessedVersion = history.macOSVersion(on: creationDate) ?? "unknown"
					currentConfigPlist["initdb_macos_version_guessed"] = guessedVersion
					configPlist	= currentConfigPlist
				}
			}
		}
	}
	
	// This function checks if the data directory was initialized (or started) on a macOS version with incompatible collations
	func checkReindexWarning() {
		serverWarning = nil
		serverWarningButtonTitle = nil
		serverWarningMessage = nil
		serverWarningInformativeText = nil

		let currentConfigPlist = configPlist
		
		// Reindex warnings only need to be shown when the user uses libc collations
		if currentConfigPlist["initdb_locale_provider"] as? String != "icu" {
			
			// The first thing we check is collation hashes
			// If the data directory has been launched with different collations
			// We know that we MUST reindex
			let collationHashes = currentConfigPlist["recently_started_collation_hash"] as? [Data] ?? []
			if collationHashes.count > 1 {
				serverWarning = "Reindexing required"
				serverWarningButtonTitle = "Learn more"
				serverWarningMessage = "Databases must be reindexed"
				serverWarningInformativeText = "This data directory has been used with an incompatible version of macOS.\n\nTo fix possible index corruption, please execute the command “REINDEX DATABASE dbname;” on every database."
				return
			}
			
			// Next thing we check is the macOS version
			// If the data directory was launched on macOS 10.15 or earlier AND on macOS 11 or later,
			// we also know that we MUST reindex
			let reindexCheckVersion =
				currentConfigPlist["reindex_warning_reset_on_macos_version"] as? String ??
				currentConfigPlist["initdb_macos_version"] as? String ??
				currentConfigPlist["initdb_macos_version_guessed"] as? String ??
				"unknown"
			
			let startedVersions = currentConfigPlist["recently_started_on_macos_versions"] as? [String] ?? []
			
			let currentVersion = ProcessInfo.processInfo.macosDisplayVersion
			
			let relevantVersions = startedVersions + [reindexCheckVersion, currentVersion]
			
			// check for mismatching macOS versions
			let containsOldVersion = relevantVersions.contains {$0 != "unknown" && "11".compare($0, options: .numeric) == .orderedDescending}
			let containsNewVersion = relevantVersions.contains {$0 != "unknown" && "11".compare($0, options: .numeric) != .orderedDescending}
			if containsOldVersion && containsNewVersion {
				serverWarning = "Reindexing required"
				serverWarningButtonTitle = "Learn more"
				serverWarningMessage = "Databases must be reindexed"
				serverWarningInformativeText = "This data directory has been used with an incompatible version of macOS.\n\nTo fix possible index corruption, please execute the command “REINDEX DATABASE dbname;” on every database."
				return
			}
			
			// If the data directory was created on an unknown macOS version, we tell the user they SHOULD reindex
			if relevantVersions.contains("unknown") {
				serverWarning = "Reindexing recommended"
				serverWarningButtonTitle = "Learn more"
				serverWarningMessage = "Databases should be reindexed"
				serverWarningInformativeText = "This data directory may have been used with an incompatible version of macOS.\n\nTo fix possible index corruption, please execute the command “REINDEX DATABASE dbname;” on every database."
				return
			}
		}
		
		// Check for reindex concurrently issue (fixed in PG 14.4)
		if let binaryVersion = binaryVersion {
			if binaryVersion.starts(with: "14") {
				let pgVersion = currentConfigPlist["reindex_warning_reset_on_postgresql_version"] as? String ?? currentConfigPlist["initdb_postgresql_version"] as? String ?? "unknown"
				let relevantPGVersions = [pgVersion] + (currentConfigPlist["recently_started_postgresql_versions"] as? [String] ?? [])
				if
					relevantPGVersions.contains("unknown") ||
					relevantPGVersions.contains(where:{ "14.4".compare($0, options: .numeric) == .orderedDescending })
				{
					serverWarning = "Reindexing recommended"
					serverWarningButtonTitle = "Learn more"
					serverWarningMessage = "Databases should be reindexed"
					serverWarningInformativeText = "There was a bug in PostgreSQL 14.3 and earlier that could corrupt indexes.\n\nAs a precaution, please execute the command “REINDEX DATABASE dbname;” on every database."
					return
				}
			}
		}
	}
	
	func showWarningDetails(modalFor window: NSWindow) {
		guard let serverWarningMessage = serverWarningMessage, let serverWarningInformativeText = serverWarningInformativeText else {
			NSSound.beep()
			return
		}
		let alert = NSAlert()
		alert.messageText = serverWarningMessage
		alert.informativeText = serverWarningInformativeText
		alert.addButton(withTitle: "OK")
		alert.addButton(withTitle: "More Info")
		alert.addButton(withTitle: "Hide This Warning")
		alert.beginSheetModal(for: window) {
			switch $0 {
			case .alertFirstButtonReturn:
				return
			case .alertSecondButtonReturn:
				NSWorkspace.shared.open(URL(string: "https://postgresapp.com/l/reindex_warning/")!)
			case .alertThirdButtonReturn:
				self.resetReindexWarning()
			default:
				break
			}
		}
	}
	
	func resetReindexWarning() {
		var currentConfigPlist = configPlist
		currentConfigPlist["previously_started_on_macos_versions"] =
			(currentConfigPlist["previously_started_on_macos_versions"] as? [String] ?? [])
			+
			(currentConfigPlist["recently_started_on_macos_versions"] as? [String] ?? [])
		currentConfigPlist["recently_started_on_macos_versions"] = nil
		currentConfigPlist["previously_started_postgresql_versions"] =
			(currentConfigPlist["previously_started_postgresql_versions"] as? [String] ?? [])
			+
			(currentConfigPlist["recently_started_postgresql_versions"] as? [String] ?? [])
		currentConfigPlist["recently_started_postgresql_versions"] = nil
		currentConfigPlist["recently_started_collation_hash"] = nil
		currentConfigPlist["reindex_warning_reset_on_macos_version"] = ProcessInfo.processInfo.macosDisplayVersion
		currentConfigPlist["reindex_warning_reset_on_postgresql_version"] = binaryVersion
		configPlist = currentConfigPlist
		checkReindexWarning()
	}
	
	/// Checks if the server is running.
	/// Must be called only from the main thread.
	func updateServerStatus() {
		if !checkBinPath() {
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
		
		checkReindexWarning()
		
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
    
    // This function returns true if
    //  - the binaries directory exists
    //  - the binaries point to a non-existing directory, but we can fix them
    //
    // As a side-effect, it sets the effectiveBinPath variable to a detected compatible binary directory
    func checkBinPath() -> Bool {
        if FileManager.default.fileExists(atPath: binPath) {
            effectiveBinPath = binPath
            return true
        }
#if IS_MAIN_APP
        let binPathComponents = binPath.components(separatedBy: "/")
        let appNameIndex = binPathComponents.lastIndex { $0.hasSuffix(".app") }
        guard let appNameIndex = appNameIndex, appNameIndex < binPathComponents.count - 1 else {
            effectiveBinPath = nil
            return false
        }
        let binPathSuffix = binPathComponents.suffix(from: appNameIndex+1).joined(separator: "/")
        for binary in BinaryManager.shared.findAvailableBinaries() {
            if binary.binPath.hasSuffix(binPathSuffix) {
                effectiveBinPath = binary.binPath
                return true
            }
        }
#endif
        effectiveBinPath = nil
        return false
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
		
		// Set the SO_REUSADDR flag to allow starting server when connections to a shut down server are still open
		// See issue: https://github.com/PostgresApp/PostgresApp/issues/676
		// The setsockopt() call shouldn't fail, so we don't check errors
		var yes = 1;
		setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &yes, socklen_t(MemoryLayout.size(ofValue: yes)));
		
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
		
		// Log the current macOS version in the config plist so we know when to show reindex warnings
		var currentConfig = configPlist
		var needWrite = false
		var recentlyStartedMacOSVersions = currentConfig["recently_started_on_macos_versions"] as? [String] ?? []
		if !recentlyStartedMacOSVersions.contains(ProcessInfo.processInfo.macosDisplayVersion) {
			recentlyStartedMacOSVersions.append(ProcessInfo.processInfo.macosDisplayVersion)
			currentConfig["recently_started_on_macos_versions"] = recentlyStartedMacOSVersions
			needWrite = true
		}
		
		// Log the current binary version
		var recentlyStartedPostgresqlVersions = currentConfig["recently_started_postgresql_versions"] as? [String] ?? []
		if let postgresqlVersion = self.binaryVersion, !recentlyStartedPostgresqlVersions.contains(postgresqlVersion) {
			recentlyStartedPostgresqlVersions.append(postgresqlVersion)
			currentConfig["recently_started_postgresql_versions"] = recentlyStartedPostgresqlVersions
			needWrite = true
		}
		
		var recentlyUsedCollationHashes = currentConfig["recently_started_collation_hash"] as? [Data] ?? []
		if let defaultCollationHash = Self.defaultCollationHash, !recentlyUsedCollationHashes.contains(defaultCollationHash) {
			recentlyUsedCollationHashes.append(defaultCollationHash)
			currentConfig["recently_started_collation_hash"] = recentlyUsedCollationHashes
			needWrite = true
		}
		
		if needWrite {
			configPlist = currentConfig
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
		let useICU: Bool
		if let binaryVersion = self.binaryVersion, "15".compare(binaryVersion, options: .numeric) != .orderedDescending {
			useICU = true
		} else {
			useICU = false
		}
		let process = Process()
		process.launchPath = binPath.appending("/initdb")
		var processArguments = [
			"-D", varPath,
			"-U", "postgres",
			"--encoding=UTF-8",
			"--locale=en_US.UTF-8"
		]
		if useICU {
			processArguments += [
				"--locale-provider=icu",
				"--icu-locale=en-US",
				"--data-checksums"
			]
		}
		process.arguments = processArguments
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
		
		// record software versions at initdb time
		var currentConfigPlist = configPlist
		currentConfigPlist["initdb_macos_version"] = ProcessInfo.processInfo.macosDisplayVersion
		currentConfigPlist["initdb_postgresql_version"] = self.binaryVersion ?? "unknown"
		if useICU {
			currentConfigPlist["initdb_locale_provider"] = "icu"
		}
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
		
	private var cachedBinaryVersion: String?
	var binaryVersion: String? {
		if let a = cachedBinaryVersion { return a }
		let process = Process()
		let launchPath = self.binPath + "/postgres"
		guard FileManager().fileExists(atPath: launchPath) else { return nil }
		process.launchPath = launchPath
		process.arguments = [
			"-V"
		]
		let outPipe = Pipe()
		process.standardOutput = outPipe
		do {
			try process.launchAndCheckForRosetta()
		} catch let error {
			print("Failed to run '\(launchPath) -V': \(error.localizedDescription)")
			return nil
		}
		process.waitUntilExit()
		let outputOrNil = String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
		guard let output = outputOrNil else { return nil }
		guard process.terminationStatus == 0 else { return nil }
		guard let splitIndex = output.lastIndex(of: " ") else { return nil }
		let versionString = output[splitIndex...]
		cachedBinaryVersion = versionString.trimmingCharacters(in: .whitespacesAndNewlines)
		return cachedBinaryVersion!
	}
	
	static let defaultCollationHash: Data? = try? {
		let data = try Data(contentsOf: URL(fileURLWithPath: "/usr/share/locale/en_US.UTF-8/LC_COLLATE"))
		var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
		data.withUnsafeBytes {
			_ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &digest)
		}
		return Data(digest)
	}()
	
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

