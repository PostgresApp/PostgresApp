//
//  PostgresServer.swift
//  Postgres
//
//  Created by Chris on 23/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class PostgresServer: NSObject, NSCoding {
	
	let BUNDLE_PATH = "/Applications/Postgres.app"
	
	enum DataDirectoryStatus {
		case Compatible
		case Incompatible
		case Empty
	}
	
	enum ServerStatus {
		case Startable
		case Running
		case NoBinDir
		case WrongDataDirectory
		case Error
	}
	
	enum ActionStatus {
		case Success
		case Failure(NSError)
	}
	
	
	dynamic var name: String = ""
	dynamic var version: String = ""
	dynamic var port: UInt = 0
	dynamic var binPath: String = ""
	dynamic var varPath: String = ""
	dynamic var runAtStartup: Bool = false
	dynamic var stopAtQuit: Bool = false
	
	dynamic private(set) var busy: Bool = false
	dynamic private(set) var statusMessage: String = ""
	dynamic private(set) var statusMessageExtended: String = ""
	dynamic private(set) var databases: [NSObject] = []
	
	dynamic private(set) var running: Bool {
		set {
			DispatchQueue.main.async { self._running = newValue }
		}
		get {
			return self._running
		}
	}
	private var _running: Bool = false {
		didSet {
			if self._running {
				self.statusMessage = "PostgreSQL \(self.version) - Running on port \(self.port)"
			} else {
				self.statusMessage = "PostgreSQL \(self.version) - Stopped"
			}
		}
	}
	
	dynamic var logfilePath: String {
		get {
			return self.varPath.appending("/postgres-server.log")
		}
	}
	
	var dataDirectoryStatus: DataDirectoryStatus {
		get {
			let pgVersionPath = self.varPath.appending("/PG_VERSION")
			if FileManager.default().fileExists(atPath: pgVersionPath) {
				do {
					let fileContents = try String(contentsOfFile: pgVersionPath)
					if fileContents.substring(to: fileContents.index(before: fileContents.endIndex)) == self.version {
						return .Compatible
					} else {
						return .Incompatible
					}
				} catch {}
			}
			return .Empty
		}
	}
	
	var serverStatus: ServerStatus {
		get {
			if !FileManager.default().fileExists(atPath: self.binPath) {
				return .NoBinDir
			}
			
			let task = Task()
			task.launchPath = self.binPath.appending("/psql")
			task.arguments = [
				"-p", String(self.port),
				"-A",
				"-q",
				"-t",
				"-c", "SHOW data_directory",
				"postgres"
			]
			let outPipe = Pipe()
			task.standardOutput = outPipe
			task.standardError = Pipe()
			task.launch()			
			let taskOutput = String(data: (outPipe.fileHandleForReading.readDataToEndOfFile()), encoding: .utf8) ?? "(incorrectly encoded error message)"
			task.waitUntilExit()
			
			switch task.terminationStatus {
			case 0:
				if taskOutput.characters.count > 0 && taskOutput.substring(to: taskOutput.index(before: taskOutput.endIndex)) == self.varPath {
					self.running = true
					return .Running
				}
				return .WrongDataDirectory
				
			case 2:
				self.running = false
				return .Startable
				
			default:
				self.running = false
				return .Error
			}
		}
	}
	
	
	convenience init(name: String, version: String, port: UInt, varPath: String) {
		self.init()
		
		self.name = name
		self.version = version
		self.port = port
		self.binPath = BUNDLE_PATH.appendingFormat("/Contents/Versions/%@/bin", self.version)
		self.varPath = varPath
		
		// TODO: read port from postgresql.conf
	}
	
	
	required convenience init(coder aDecoder: NSCoder) {
		self.init()
		
		guard let name = aDecoder.decodeObject(forKey: "name") as? String else { return }
		guard let version = aDecoder.decodeObject(forKey: "version") as? String else { return }
		guard let port = aDecoder.decodeObject(forKey: "port") as? UInt else { return }
		guard let varPath = aDecoder.decodeObject(forKey: "varPath") as? String else { return }
		
		self.name = name
		self.version = version
		self.port = port
		self.binPath = BUNDLE_PATH.appendingFormat("/Contents/Versions/%@/bin", self.version)
		self.varPath = varPath
		self.runAtStartup = aDecoder.decodeBool(forKey: "runAtStartup")
		self.stopAtQuit = aDecoder.decodeBool(forKey: "stopAtQuit")
	}
	
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(name, forKey: "name")
		aCoder.encode(version, forKey: "version")
		aCoder.encode(UInt(port), forKey: "port")
		aCoder.encode(binPath, forKey: "binPath")
		aCoder.encode(varPath, forKey: "varPath")
		aCoder.encode(runAtStartup, forKey: "runAtStartup")
		aCoder.encode(stopAtQuit, forKey: "stopAtQuit")
	}
	
	
	
	/*
	public async handlers
	*/
	func start(completionHandler: (_: ActionStatus) -> Void) {
		self.busy = true
		
		DispatchQueue.global().async {
			switch self.dataDirectoryStatus {
			
			case .Empty:
				let initRes = self.initDatabaseSync()
				if case .Failure = initRes {
					DispatchQueue.main.async {
						completionHandler(initRes)
					}
				}
				
				let startRes = self.startSync()
				if case .Failure = startRes {
					DispatchQueue.main.async {
						completionHandler(startRes)
					}
				}
				
				let createUserRes = self.createUserSync()
				if case .Failure = createUserRes {
					DispatchQueue.main.async {
						completionHandler(createUserRes)
					}
				}
				
				let createDBRes = self.createUserDatabaseSync()
				if case .Failure = createDBRes {
					DispatchQueue.main.async {
						completionHandler(createDBRes)
					}
				}
				
			case .Incompatible:
				let userInfo: [String: AnyObject] = [
					NSLocalizedDescriptionKey: NSLocalizedString("The data directory is not compatible with this version of PostgreSQL server.", comment: ""),
					NSLocalizedRecoverySuggestionErrorKey: "Please create a new Server."
				]
				let error = NSError(domain: "com.postgresapp.Postgres.data-directory", code: 0, userInfo: userInfo)
				DispatchQueue.main.async {
					completionHandler(.Failure(error))
				}
				
			case .Compatible:
				print(self.serverStatus)
				switch self.serverStatus {
				case .Running:
					let userInfo: [String: AnyObject] = [
						NSLocalizedDescriptionKey: "This PostgreSQL server is already running on port \(self.port)",
						NSLocalizedRecoverySuggestionErrorKey: "Please stop this server before starting again."
					]
					let error = NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo)
					DispatchQueue.main.async {
						completionHandler(.Failure(error))
					}
					
				case .NoBinDir:
					let userInfo: [String: AnyObject] = [
						NSLocalizedDescriptionKey: "The binaries for this PostgreSQL server were not found",
						NSLocalizedRecoverySuggestionErrorKey: "Create a new Server and try again."
					]
					let error = NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo)
					DispatchQueue.main.async {
						completionHandler(.Failure(error))
					}
					
				case .WrongDataDirectory:
					let userInfo: [String: AnyObject] = [
						NSLocalizedDescriptionKey: "There is already a PostgreSQL server running on port \(self.port)",
						NSLocalizedRecoverySuggestionErrorKey: "Please stop this server before.\n\nIf you want to use multiple servers, configure them to use different ports."
					]
					let error = NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo)
					DispatchQueue.main.async {
						completionHandler(.Failure(error))
					}
					
				case .Error:
					let userInfo: [String: AnyObject] = [
						NSLocalizedDescriptionKey: "Unknown error",
						NSLocalizedRecoverySuggestionErrorKey: ""
					]
					let error = NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo)
					DispatchQueue.main.async {
						completionHandler(.Failure(error))
					}
					
				case .Startable:
					let startRes = self.startSync()
					DispatchQueue.main.async {
						completionHandler(startRes)
					}
					
				}
			}
			
			DispatchQueue.main.async {
				self.busy = false
			}
		}
	}
	
	
	func stop(completionHandler: (_: ActionStatus) -> Void) {
		self.busy = true
		
		DispatchQueue.global().async {
			
			let stopRes = self.stopSync()
			DispatchQueue.main.async {
				completionHandler(stopRes)
			}
			
			DispatchQueue.main.async {
				self.busy = false
			}
		}
	}
	
	
	/*
	sync handlers
	*/
	private func startSync() -> ActionStatus {
		let task = Task()
		task.launchPath = self.binPath.appending("/pg_ctl")
		task.arguments = [
			"start",
			"-D", self.varPath,
			"-w",
			"-l", self.logfilePath,
			"-o", String("-p \(self.port)"),
		]
		task.standardOutput = Pipe()
		task.standardError = Pipe()
		task.launch()
		let errorDescription = String(data: (task.standardError?.fileHandleForReading.readDataToEndOfFile())!, encoding: .utf8) ?? "(incorrectly encoded error message)"
		task.waitUntilExit()
		
		if task.terminationStatus == 0 {
			self.running = true
			return .Success
		}
		else {
			let userInfo: [String: AnyObject] = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not start PostgreSQL server.", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
				NSLocalizedRecoveryOptionsErrorKey: ["OK", "Open Server Log"],
				NSRecoveryAttempterErrorKey: ErrorRecoveryAttempter(recoveryAttempter: { (error, optionIndex) -> Bool in
					if optionIndex == 1 {
						NSWorkspace.shared().openFile(self.logfilePath, withApplication: "Console")
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
		task.launchPath = self.binPath.appending("/pg_ctl")
		task.arguments = [
			"stop",
			"-m", "f",
			"-D", self.varPath,
			"-w",
		]
		task.standardOutput = Pipe()
		task.standardError = Pipe()
		task.launch()
		let errorDescription = String(data: (task.standardError?.fileHandleForReading.readDataToEndOfFile())!, encoding: .utf8) ?? "(incorrectly encoded error message)"
		task.waitUntilExit()
		
		if task.terminationStatus == 0 {
			self.running = false
			return .Success
		}
		else {
			let userInfo: [String: AnyObject] = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not stop PostgreSQL server.", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
				NSLocalizedRecoveryOptionsErrorKey: ["OK", "Open Server Log"],
				NSRecoveryAttempterErrorKey: ErrorRecoveryAttempter(recoveryAttempter: { (error, optionIndex) -> Bool in
					if optionIndex == 1 {
						NSWorkspace.shared().openFile(self.logfilePath, withApplication: "Console")
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
		task.launchPath = self.binPath.appending("/initdb")
		task.arguments = [
			"-D", self.varPath,
			"-U", "postgres",
			"--encoding=UTF-8",
			"--locale=en_US.UTF-8"
		]
		task.standardOutput = Pipe()
		task.standardError = Pipe()
		task.launch()
		let errorDescription = String(data: (task.standardError?.fileHandleForReading.readDataToEndOfFile())!, encoding: .utf8) ?? "(incorrectly encoded error message)"
		task.waitUntilExit()
		
		if task.terminationStatus == 0 {
			return .Success
		}
		else {
			let userInfo: [String: AnyObject] = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not initialize database cluster.", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
				NSLocalizedRecoveryOptionsErrorKey: ["OK", "Open Server Log"],
				NSRecoveryAttempterErrorKey: ErrorRecoveryAttempter(recoveryAttempter: { (error, optionIndex) -> Bool in
					if optionIndex == 1 {
						NSWorkspace.shared().openFile(self.logfilePath, withApplication: "Console")
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
		task.launchPath = self.binPath.appending("/createuser")
		task.arguments = [
			"-U", "postgres",
			"-p", String(self.port),
			"--superuser",
			NSUserName()
		]
		task.standardOutput = Pipe()
		task.standardError = Pipe()
		task.launch()
		let errorDescription = String(data: (task.standardError?.fileHandleForReading.readDataToEndOfFile())!, encoding: .utf8) ?? "(incorrectly encoded error message)"
		task.waitUntilExit()
		
		if task.terminationStatus == 0 {
			return .Success
		}
		else {
			let userInfo: [String: AnyObject] = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not create default user.", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
				NSLocalizedRecoveryOptionsErrorKey: ["OK", "Open Server Log"],
				NSRecoveryAttempterErrorKey: ErrorRecoveryAttempter(recoveryAttempter: { (error, optionIndex) -> Bool in
					if optionIndex == 1 {
						NSWorkspace.shared().openFile(self.logfilePath, withApplication: "Console")
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
		task.launchPath = self.binPath.appending("/createdb")
		task.arguments = [
			"-p", String(self.port),
			NSUserName()
		]
		task.standardOutput = Pipe()
		task.standardError = Pipe()
		task.launch()
		let errorDescription = String(data: (task.standardError?.fileHandleForReading.readDataToEndOfFile())!, encoding: .utf8) ?? "(incorrectly encoded error message)"
		task.waitUntilExit()
		
		if task.terminationStatus == 0 {
			return .Success
		}
		else {
			let userInfo: [String: AnyObject] = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not create user database.", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: errorDescription,
				NSLocalizedRecoveryOptionsErrorKey: ["OK", "Open Server Log"],
				NSRecoveryAttempterErrorKey: ErrorRecoveryAttempter(recoveryAttempter: { (error, optionIndex) -> Bool in
					if optionIndex == 1 {
						NSWorkspace.shared().openFile(self.logfilePath, withApplication: "Console")
					}
					return true
				})
			]
			let error = NSError(domain: "com.postgresapp.Postgres.createdb", code: Int(task.terminationStatus), userInfo: userInfo)
			return .Failure(error)
		}
	}
	
}




class DatabaseModel {
	
	var name: String = ""
	
}
