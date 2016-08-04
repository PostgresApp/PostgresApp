//
//  Server.swift
//  Postgres
//
//  Created by Chris on 01/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class Server: NSObject, NSCoding {
	
	enum ServerStatus {
		case Startable
		case Running
		case NoBinDir
		case WrongDataDirectory
		case Error
		case DataDirIncompatible
		case DataDirEmpty
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
	dynamic var startAtLogin: Bool = false
	
	dynamic var configFilePath: String {
		return self.varPath.appending("/postgresql.conf")
	}
	dynamic var hbaFilePath: String {
		return self.varPath.appending("/pg_hba.conf")
	}
	dynamic var logFilePath: String {
		return self.varPath.appending("/postgresql.log")
	}
	
	dynamic private(set) var busy: Bool = false
	dynamic private(set) var running: Bool = false
	dynamic private(set) var statusMessage: String = ""
	dynamic private(set) var statusMessageExtended: String = ""
	dynamic private(set) var databases: [Database] = []
	
	private(set) var serverStatus: ServerStatus = .Error
	
	
	convenience init(name: String, version: String? = nil, port: UInt = 5432, varPath: String? = nil) {
		self.init()
		
		self.name = name
		self.version = version ?? Bundle.main().objectForInfoDictionaryKey("LatestStablePostgresVersion") as? String ?? "9.5"
		self.port = port
		self.binPath = AppDelegate.BUNDLE_PATH.appendingFormat("/Contents/Versions/%@/bin", self.version)
		self.varPath = varPath ?? ""
		
		if self.varPath == "" {
			if let path = FileManager().applicationSupportDirectoryPath(createIfNotExists: true) {
				self.varPath = path.appending("/var-\(self.version)")
			}
		}
		
		self.updateServerStatus()
		
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
		self.binPath = AppDelegate.BUNDLE_PATH.appendingFormat("/Contents/Versions/%@/bin", version)
		self.varPath = varPath
		self.startAtLogin = startAtLogin
	}
	
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(self.name, forKey: "name")
		aCoder.encode(self.version, forKey: "version")
		aCoder.encode(UInt(self.port), forKey: "port")
		aCoder.encode(self.binPath, forKey: "binPath")
		aCoder.encode(self.varPath, forKey: "varPath")
		aCoder.encode(self.startAtLogin, forKey: "startAtLogin")
	}
	
	
	
	/*
	public async handlers
	*/
	func start(closure: (_: ActionStatus) -> Void) {
		self.busy = true
		
		DispatchQueue.global().async {
			
			DispatchQueue.main.sync {
				self.updateServerStatus()
			}
			
			switch self.serverStatus {
			
			case .DataDirIncompatible:
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("The data directory is not compatible with this version of PostgreSQL server.", comment: ""),
					NSLocalizedRecoverySuggestionErrorKey: "Please create a new Server."
				]
				let error = NSError(domain: "com.postgresapp.Postgres.data-directory", code: 0, userInfo: userInfo)
				DispatchQueue.main.async {
					closure(.Failure(error))
				}
				
			case .NoBinDir:
				let userInfo = [
					NSLocalizedDescriptionKey: "The binaries for this PostgreSQL server were not found",
					NSLocalizedRecoverySuggestionErrorKey: "Create a new Server and try again."
				]
				let error = NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo)
				DispatchQueue.main.async {
					closure(.Failure(error))
				}
				
			case .WrongDataDirectory:
				let userInfo = [
					NSLocalizedDescriptionKey: "There is already a PostgreSQL server running on port \(self.port)",
					NSLocalizedRecoverySuggestionErrorKey: "Please stop this server before.\n\nIf you want to use multiple servers, configure them to use different ports."
				]
				let error = NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo)
				DispatchQueue.main.async {
					closure(.Failure(error))
				}
				
			case .Error:
				let userInfo = [
					NSLocalizedDescriptionKey: "Unknown error",
					NSLocalizedRecoverySuggestionErrorKey: ""
				]
				let error = NSError(domain: "com.postgresapp.Postgres.server-status", code: 0, userInfo: userInfo)
				DispatchQueue.main.async {
					closure(.Failure(error))
				}
				
			case .DataDirEmpty:
				let initRes = self.initDatabaseSync()
				if case .Failure = initRes {
					DispatchQueue.main.async {
						closure(initRes)
					}
				}
				
				let startRes = self.startSync()
				if case .Failure = startRes {
					DispatchQueue.main.async {
						closure(startRes)
					}
				}
				
				let createUserRes = self.createUserSync()
				if case .Failure = createUserRes {
					DispatchQueue.main.async {
						closure(createUserRes)
					}
				}
				
				let createDBRes = self.createUserDatabaseSync()
				if case .Failure = createDBRes {
					DispatchQueue.main.async {
						closure(createDBRes)
					}
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
				
			}
			
			DispatchQueue.main.async {
				self.busy = false
			}
			
		}
	}
	
	/// Attempts to stop the server (in a background thread)
	/// - parameter closure: This block will be called on the main thread when the server has stopped.
	func stop(closure: (_: ActionStatus) -> Void) {
		self.busy = true
		
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
		if !FileManager.default().fileExists(atPath: self.binPath) {
			self.running = false
			self.serverStatus = .NoBinDir
			self.statusMessage = "No binaries found."
			self.databases.removeAll()
			return
		}
		
		let pgVersionPath = self.varPath.appending("/PG_VERSION")
		
		if !FileManager.default().fileExists(atPath: pgVersionPath) {
			self.running = false
			self.serverStatus =  .DataDirEmpty
			self.statusMessage = "Click ‘Start’ to initialise the server."
			self.databases.removeAll()
			return
		}
		
		do {
			let fileContents = try String(contentsOfFile: pgVersionPath)
			guard self.version == fileContents.substring(to: fileContents.index(before: fileContents.endIndex)) else {
				self.running = false
				self.serverStatus =  .DataDirIncompatible
				self.statusMessage = "Database directory incompatible."
				self.databases.removeAll()
				return
				
			}
		} catch {
			self.running = false
			self.serverStatus = .Error
			self.statusMessage = "Could not determine data directory version."
			self.databases.removeAll()
			return
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
				self.serverStatus = .Running
				self.statusMessage = "PostgreSQL \(self.version) - Running on port \(self.port)"
				self.loadDatabases()
				return
			} else {
				self.running = false
				self.serverStatus = .WrongDataDirectory
				self.statusMessage = "A different server is running on port \(self.port)."
				self.databases.removeAll()
				return
			}
			
		case 2:
			self.running = false
			self.serverStatus = .Startable
			self.statusMessage = "Not running."
			self.databases.removeAll()
			return

		default:
			self.running = false
			self.serverStatus = .Error
			self.statusMessage = "Server status could not be determined."
			self.databases.removeAll()
			return
		}
	}
	
	
	func loadDatabases() {
		self.databases.removeAll()
		
		let url = "postgresql://:\(self.port)"
		let connection = PQconnectdb(url.cString(using: .utf8))
		
		if PQstatus(connection) == CONNECTION_OK {
			
			let result = PQexec(connection, "SELECT datname FROM pg_database WHERE datallowconn ORDER BY LOWER(datname)")
			for i in 0...PQntuples(result)-1 {
				let value = PQgetvalue(result, i, 0)
				let name = String(cString: value!)
				self.databases.append(Database(name))
			}
			PQfinish(connection)
			
		} else {
			print("postgresql: CONNECTION_BAD")
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
			"-l", self.logFilePath,
			"-o", String("-p \(self.port)"),
		]
		task.standardOutput = Pipe()
		let errorPipe = Pipe()
		task.standardError = errorPipe
		task.launch()
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		task.waitUntilExit()
		
		if task.terminationStatus == 0 {
			DispatchQueue.main.sync {
				self.updateServerStatus()
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
		task.launchPath = self.binPath.appending("/pg_ctl")
		task.arguments = [
			"stop",
			"-m", "f",
			"-D", self.varPath,
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
				self.updateServerStatus()
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
		task.launchPath = self.binPath.appending("/initdb")
		task.arguments = [
			"-D", self.varPath,
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
		task.launchPath = self.binPath.appending("/createuser")
		task.arguments = [
			"-U", "postgres",
			"-p", String(self.port),
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
		task.launchPath = self.binPath.appending("/createdb")
		task.arguments = [
			"-p", String(self.port),
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

