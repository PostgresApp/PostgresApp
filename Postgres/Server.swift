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
	var extPath: String {
		var components = binPath.components(separatedBy: "/")
		while let last = components.last, last.isEmpty || last == "." {
			components.removeLast()
		}
		if components.last == "bin" {
			components.removeLast()
		}
		components.append("lib")
		components.append("postgresql")
		return components.joined(separator: "/")
	}
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
	
	func readConfigPlist() throws -> [String: Any] {
        let data = try Data(contentsOf: URL(fileURLWithPath: configPlistPath))
        let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
        guard let configPlist = plist as? [String:Any] else {
            throw NSError()
        }
        return configPlist
	}
    
    func writeConfigPlist(_ newValue:[String: Any]) throws {
        let data = try PropertyListSerialization.data(fromPropertyList: newValue, format: .xml, options: 0)
        try data.write(to: URL(fileURLWithPath: configPlistPath))
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
	func start(_ completion: @escaping (Result<Void, Error>) -> Void) {
		busy = true
		updateServerStatus()
        
        if let effectiveBinPath = effectiveBinPath, binPath != effectiveBinPath {
            binPath = effectiveBinPath
        }
		
		DispatchQueue.global().async {
			let statusResult: Result<Void, Error>
			
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
				statusResult = .failure(NSError(domain: "com.postgresapp.Postgres2.server-status", code: 0, userInfo: userInfo))
				
			case .PortInUse:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("Port \(self.port) is already in use", comment: ""),
					NSLocalizedRecoverySuggestionErrorKey: "Usually this means that there is already a PostgreSQL server running on your Mac. If you want to run multiple servers simultaneously, use different ports."
				]
				statusResult = .failure(NSError(domain: "com.postgresapp.Postgres2.server-status", code: 0, userInfo: userInfo))
				
			case .DataDirInUse:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("There is already a PostgreSQL server running in this data directory", comment: ""),
				]
				statusResult = .failure(NSError(domain: "com.postgresapp.Postgres2.server-status", code: 0, userInfo: userInfo))
				
			case .DataDirEmpty:
                statusResult = Result {
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
				statusResult = .success(())
				
			case .Startable:
                statusResult = Result {
                    try self.startSync()
                }
				
			case .StalePidFile:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("The data directory contains an old postmaster.pid file", comment: ""),
					NSLocalizedRecoverySuggestionErrorKey: "The data directory contains a postmaster.pid file, which usually means that the server is already running. When the server crashes or is killed, you have to remove this file before you can restart the server. Make sure that the database process is definitely not running anymore, otherwise your data directory will be corrupted."
				]
				statusResult = .failure(NSError(domain: "com.postgresapp.Postgres2.server-status", code: 0, userInfo: userInfo))
				
			case .PidFileUnreadable:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("The data directory contains an unreadable postmaster.pid file", comment: "")
				]
				statusResult = .failure(NSError(domain: "com.postgresapp.Postgres2.server-status", code: 0, userInfo: userInfo))
				
			case .Unknown:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("Unknown server status", comment: "")
				]
				statusResult = .failure(NSError(domain: "com.postgresapp.Postgres2.server-status", code: 0, userInfo: userInfo))
				
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
	func stop(_ completion: @escaping (Result<Void, Error>) -> Void) {
		busy = true
		
		DispatchQueue.global().async {
            let stopRes = Result {
                try self.stopSync()
            }
			DispatchQueue.main.async {
				self.updateServerStatus()
				completion(stopRes)
				self.busy = false
			}
		}
	}
	
    func changePassword(role: String, newPassword: String, _ completion: @escaping (Result<Void, Error>) -> Void) {
        busy = true
        
        DispatchQueue.global().async {
            let stopRes = Result {
                try self.changePasswordSync(role: role, newPassword: newPassword)
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
        var configPlist = (try? readConfigPlist()) ?? [:]
		
		// check if there is already a macos version stored
		if  configPlist["initdb_macos_version"] is String || configPlist["initdb_macos_version_guessed"] is String {
			return
		}
		
		//no previous guess, we need to make a guess now
		if let history = InstallHistory.local {
			if let pgVersionAttributes = try? FileManager().attributesOfItem(atPath: pgVersionPath) {
				if let creationDate = pgVersionAttributes[.creationDate] as? Date {
					let guessedVersion = history.macOSVersion(on: creationDate) ?? "unknown"
					configPlist["initdb_macos_version_guessed"] = guessedVersion
					try? writeConfigPlist(configPlist)
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

        guard let configPlist = try? readConfigPlist() else {
            // if there is no config plist
            // we don't perform a check
            return
        }
		
		// Reindex warnings only need to be shown when the user uses libc collations
		if configPlist["initdb_locale_provider"] as? String != "icu" {
			
			// The first thing we check is collation hashes
			// If the data directory has been launched with different collations
			// We know that we MUST reindex
			let collationHashes = configPlist["recently_started_collation_hash"] as? [Data] ?? []
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
				configPlist["reindex_warning_reset_on_macos_version"] as? String ??
				configPlist["initdb_macos_version"] as? String ??
				configPlist["initdb_macos_version_guessed"] as? String ??
				"unknown"
			
			let startedVersions = configPlist["recently_started_on_macos_versions"] as? [String] ?? []
			
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
				let pgVersion = configPlist["reindex_warning_reset_on_postgresql_version"] as? String ?? configPlist["initdb_postgresql_version"] as? String ?? "unknown"
				let relevantPGVersions = [pgVersion] + (configPlist["recently_started_postgresql_versions"] as? [String] ?? [])
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
        var configPlist = (try? readConfigPlist()) ?? [:]
		configPlist["previously_started_on_macos_versions"] =
			(configPlist["previously_started_on_macos_versions"] as? [String] ?? [])
			+
			(configPlist["recently_started_on_macos_versions"] as? [String] ?? [])
		configPlist["recently_started_on_macos_versions"] = nil
		configPlist["previously_started_postgresql_versions"] =
			(configPlist["previously_started_postgresql_versions"] as? [String] ?? [])
			+
			(configPlist["recently_started_postgresql_versions"] as? [String] ?? [])
		configPlist["recently_started_postgresql_versions"] = nil
		configPlist["recently_started_collation_hash"] = nil
		configPlist["reindex_warning_reset_on_macos_version"] = ProcessInfo.processInfo.macosDisplayVersion
		configPlist["reindex_warning_reset_on_postgresql_version"] = binaryVersion
		try? writeConfigPlist(configPlist)
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
	
	func authDialogOptions() throws -> [String] {
		
		// First make sure the auth permission dialog extension is available
		if !UserDefaults.standard.bool(forKey: UserDefaults.PermissionDialogForTrustAuthKey) {
			return []
		}
		
		// First make sure the auth permission dialog extension is available
		guard FileManager().fileExists(atPath: extPath.appending("/auth_permission_dialog.dylib")) || FileManager().fileExists(atPath: extPath.appending("/auth_permission_dialog.so")) else {
			let userInfo: [String: Any] = [
				NSLocalizedDescriptionKey: NSLocalizedString("The auth_permission_dialog extension wasn't found.", comment: ""),
			]
			throw NSError(domain: "com.postgresapp.Postgres2.postgres", code: 0, userInfo: userInfo)
		}
		
		let process = Process()
		let launchPath = binPath.appending("/postgres")
		guard FileManager().fileExists(atPath: launchPath) else {
			let userInfo: [String: Any] = [
				NSLocalizedDescriptionKey: NSLocalizedString("The binaries for this PostgreSQL server were not found.", comment: ""),
			]
			throw NSError(domain: "com.postgresapp.Postgres2.postgres", code: 0, userInfo: userInfo)
		}
		process.launchPath = launchPath
		process.arguments = [
			"-D", varPath,
			"-C",
			"shared_preload_libraries",
		]
		let standardOutputPipe = Pipe()
		process.standardOutput = standardOutputPipe
		let errorPipe = Pipe()
		process.standardError = errorPipe
		try process.launchAndCheckForRosetta()
		guard let standardOutputString = String(data: standardOutputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) else {
			let userInfo: [String: Any] = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not read PostgreSQL server settings", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString("Standard output from postgres -C could not be read.", comment: ""),
			]
			throw NSError(domain: "com.postgresapp.Postgres2.postgres", code: 0, userInfo: userInfo)
		}
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		process.waitUntilExit()
		
		guard process.terminationStatus == 0 else {
			let userInfo: [String: Any] = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not read PostgreSQL server settings", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
			]
			throw NSError(domain: "com.postgresapp.Postgres2.postgres", code: 0, userInfo: userInfo)
		}
		

		let oldLibs = standardOutputString.components(separatedBy: ",").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)}).filter { !$0.isEmpty }
		let newLibs = oldLibs.filter({$0 != "auth_permission_dialog"}) + ["auth_permission_dialog"]
		let libsvalue = newLibs.joined(separator: ",")
		
		guard let newExecutablePath = Bundle.main.path(forAuxiliaryExecutable: "PostgresPermissionDialog") else {
			throw NSError(domain: "com.postgresapp.Postgres2", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find PostgresPermissionDialog executable"])
		}

		// quote a value
		// pg_ctl uses a shell to start postmaster
		// therefore parameters must be quoted like shell arguments
		func shqu(_ str: String) -> String {
			"'" + str.replacingOccurrences(of: "'", with: "'\''") + "'"
		}
		
		return [
			"-o", "-c shared_preload_libraries=\(shqu(libsvalue))",
			"-o", "-c auth_permission_dialog.dialog_executable_path=\(shqu(newExecutablePath))"
		]
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
		let extraArgs = try authDialogOptions()
		
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
			"-o", "-p \(port)",
		] + extraArgs
		let outputPipe = Pipe()
		let errorPipe = Pipe()
		process.standardOutput = outputPipe
		process.standardError = errorPipe
        try process.launchAndCheckForRosetta()
		let (_, error) = try readHandlesToEnd(outputPipe.fileHandleForReading, errorPipe.fileHandleForReading)
		let errorDescription = String(data: error, encoding: .utf8) ?? "(incorrectly encoded error message)"
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
        var configPlist = (try? readConfigPlist()) ?? [:]
		var needWrite = false
		var recentlyStartedMacOSVersions = configPlist["recently_started_on_macos_versions"] as? [String] ?? []
		if !recentlyStartedMacOSVersions.contains(ProcessInfo.processInfo.macosDisplayVersion) {
			recentlyStartedMacOSVersions.append(ProcessInfo.processInfo.macosDisplayVersion)
			configPlist["recently_started_on_macos_versions"] = recentlyStartedMacOSVersions
			needWrite = true
		}
		
		// Log the current binary version
		var recentlyStartedPostgresqlVersions = configPlist["recently_started_postgresql_versions"] as? [String] ?? []
		if let postgresqlVersion = self.binaryVersion, !recentlyStartedPostgresqlVersions.contains(postgresqlVersion) {
			recentlyStartedPostgresqlVersions.append(postgresqlVersion)
			configPlist["recently_started_postgresql_versions"] = recentlyStartedPostgresqlVersions
			needWrite = true
		}
		
		var recentlyUsedCollationHashes = configPlist["recently_started_collation_hash"] as? [Data] ?? []
		if let defaultCollationHash = Self.defaultCollationHash, !recentlyUsedCollationHashes.contains(defaultCollationHash) {
			recentlyUsedCollationHashes.append(defaultCollationHash)
			configPlist["recently_started_collation_hash"] = recentlyUsedCollationHashes
			needWrite = true
		}
		
		if needWrite {
			try? writeConfigPlist(configPlist)
		}
	}
	
	func readHandlesToEnd(_ h1: FileHandle, _ h2: FileHandle) throws -> (Data, Data) {
		typealias resultType = (Data, Data)
		var result = (Data(), Data())
		var fds = [
			pollfd(fd: h1.fileDescriptor, events: Int16(POLLIN), revents: 0),
			pollfd(fd: h2.fileDescriptor, events: Int16(POLLIN), revents: 0),
		]
		var handles = [
			h1,
			h2
		]
		var resultPaths = [
			\resultType.0,
			\resultType.1,
		]
		while true {
			let pollres = poll(&fds, nfds_t(fds.count), -1)
			if pollres < 0 {
				let code = Int(errno)
				let errStr = String(cString: strerror(errno))
				throw NSError(
					domain: "com.postgresapp.Postgres2",
					code: code,
					userInfo: [
						NSLocalizedDescriptionKey: "poll() failed: \(errStr)"
					]
				)
			}
			for i in fds.indices.reversed() {
				if (fds[i].revents & Int16(POLLIN)) != 0 {
					let availableData: Data
					if #available(macOS 10.15.4, *) {
						availableData = try handles[i].read(upToCount: Int.max) ?? Data()
					} else {
						availableData = handles[i].availableData
					}
					if availableData.count == 0 {
						// eof
						fds.remove(at: i)
						handles.remove(at: i)
						resultPaths.remove(at: i)
					} else {
						result[keyPath: resultPaths[i]].append(availableData)
					}
				}
			}
			if fds.isEmpty {
				break
			}
		}
		return result
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
        var configPlist = (try? readConfigPlist()) ?? [:]
		configPlist["initdb_macos_version"] = ProcessInfo.processInfo.macosDisplayVersion
		configPlist["initdb_postgresql_version"] = self.binaryVersion ?? "unknown"
		if useICU {
			configPlist["initdb_locale_provider"] = "icu"
		}
		try? writeConfigPlist(configPlist)
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
		
    func changePasswordSync(role: String, newPassword: String) throws {
		do {
			try executeSingleUserModeQuerySync(
				"ALTER ROLE \"\(role.replacingOccurrences(of:"\"", with: "\"\""))\" WITH PASSWORD '\(newPassword.replacingOccurrences(of:"'", with: "''"))';\n"
			)
		}
		catch let error {
			throw NSError(
				domain: "com.postgresapp.Postgres2.postgres",
				code: 0,
				userInfo: [
					NSLocalizedDescriptionKey: NSLocalizedString("Could not update password", comment: ""),
					NSLocalizedRecoverySuggestionErrorKey: error.localizedDescription,
				]
			)
		}
	}
	
	func getRolesThatCanLoginSync() throws -> [String] {
		do {
			let results = try executeSingleUserModeQuerySync(
				"SELECT rolname FROM pg_catalog.pg_roles WHERE rolcanlogin;\n",
				columns: ["rolname"]
			)
			return results[0]
		}
		catch let error {
			throw NSError(
				domain: "com.postgresapp.Postgres2.postgres",
				code: 0,
				userInfo: [
					NSLocalizedDescriptionKey: NSLocalizedString("Could not get list of users", comment: ""),
					NSLocalizedRecoverySuggestionErrorKey: error.localizedDescription,
				]
			)
		}
	}
	
	@discardableResult
	func executeSingleUserModeQuerySync(_ query: String, columns: [String] = []) throws -> [[String]] {
		if serverStatus == .DataDirEmpty {
			let userInfo: [String: Any] = [
				NSLocalizedDescriptionKey: NSLocalizedString("Server is not initialised yet", comment: ""),
			]
			throw NSError(domain: "com.postgresapp.Postgres2.postgres", code: 0, userInfo: userInfo)
		}
		if let effectiveBinPath = effectiveBinPath, binPath != effectiveBinPath {
			binPath = effectiveBinPath
		}
		let launchPath = binPath.appending("/postgres")
		guard FileManager().fileExists(atPath: launchPath) else {
			let userInfo: [String: Any] = [
				NSLocalizedDescriptionKey: NSLocalizedString("The binaries were not found.", comment: ""),
			]
			throw NSError(domain: "com.postgresapp.Postgres2.postgres", code: 0, userInfo: userInfo)
		}
		let process = Process()
		process.launchPath = launchPath
		process.arguments = [
			"--single",
			"-D", varPath,
			"postgres"
		]
		let inputPipe = Pipe()
		process.standardInput = inputPipe
		let outputPipe = Pipe()
		process.standardOutput = outputPipe
		let errorPipe = Pipe()
		process.standardError = errorPipe
		try process.launchAndCheckForRosetta()
		if #available(macOS 10.15.4, *) {
			try inputPipe.fileHandleForWriting.write(contentsOf: query.data(using: .utf8)!)
		} else {
			// Fallback on earlier versions
			inputPipe.fileHandleForWriting.write(query.data(using: .utf8)!)
		}
		inputPipe.fileHandleForWriting.closeFile()
		let output = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		let criticalErrors = errorDescription.components(separatedBy: .newlines).compactMap { errorLine in
			let regex = try! NSRegularExpression(pattern: "(ERROR|FATAL|PANIC):\\s*(.*)$")
			if let match = regex.firstMatch(in: errorLine, range: NSMakeRange(0, errorLine.utf16.count)) {
				return (errorLine as NSString).substring(with: match.range(at: 2))
			} else {
				return nil
			}
		}
		process.waitUntilExit()
		
		guard process.terminationStatus == 0 && criticalErrors.isEmpty else {
			let userInfo: [String: Any] = [
				NSLocalizedDescriptionKey: criticalErrors.first ?? errorDescription,
			]
			throw NSError(domain: "com.postgresapp.Postgres2.postgres", code: Int(process.terminationStatus), userInfo: userInfo)
		}
		
		var results = [[String]]()
		for column in columns {
			var columnValues = [String]()
			let regex = try NSRegularExpression(pattern: "\(NSRegularExpression.escapedPattern(for: column)) = \"(.*)\"")
			for match in regex.matches(in: output, range: NSMakeRange(0, output.utf16.count)) {
				let columnValue = (output as NSString).substring(with: match.range(at: 1))
				columnValues.append(columnValue)
			}
			results.append(columnValues)
		}
		if results.count >= 2 {
			for i in 1..<results.count {
				if results[i-1].count != results[i].count {
					throw NSError(domain: "com.postgresapp.Postgres2.postgres", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse query result"]);
				}
			}
		}
		return results
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

