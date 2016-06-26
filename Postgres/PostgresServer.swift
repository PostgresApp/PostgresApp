//
//  PostgresServer.swift
//  Postgres
//
//  Created by Chris on 23/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

@objc class PostgresServer: NSObject, NSCoding {
	
	let BUNDLE_PATH = "/Applications/Postgres.app"
	
	enum DataDirectoryStatus {
		case Incompatible
		case Compatible
		case Empty
	}
	
	enum ServerStatus {
		case Unreachable
		case Running
		case WrongDataDirectory
		case Error
		case NoBinDir
	}
	
	
	dynamic var name: String = ""
	dynamic var version: String = ""
	dynamic var port: UInt = 0
	dynamic var binPath: String = ""
	dynamic var varPath: String = ""
	dynamic var runAtStartup: Bool = false
	dynamic var stopAtQuit: Bool = true
	
	dynamic private(set) var running: Bool = false
	dynamic private(set) var busy: Bool = false
	dynamic private(set) var databases: [NSObject] = []
	
	dynamic var statusMessage: String {
		get {
			if self.running {
				return "PostgreSQL \(self.version) - Running on port \(self.port)"
			}
			else {
				return "PostgreSQL \(self.version) - Stopped"
			}
		}
	}
	
	dynamic var statusMessageExtended: String {
		get {
			if self.running {
				return "PostgreSQL \(self.version) - Running on port \(self.port)"
			}
			else {
				return "PostgreSQL \(self.version) - Stopped"
			}
		}
	}
	
	var logfilePath: String {
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
					if String(fileContents.characters.split(separator: Character("\n")).first!) == self.version {
						return .Compatible
					}
					else {
						return .Incompatible
					}
				} catch {}
			}
			return .Empty
		}
	}
	
	var serverStatus: ServerStatus {
		get {
			return .Error
		}
	}
	
	
	override init() {
		// TODO: read port from postgresql.conf
	}
	
	
	convenience init(name: String, version: String, port: UInt, varPath: String) {
		self.init()
		
		self.name = name
		self.version = version
		self.port = port
		self.binPath = BUNDLE_PATH.appendingFormat("/Contents/Versions/%@/bin", self.version)
		self.varPath = varPath
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
		aCoder.encode(port, forKey: "port")
		aCoder.encode(binPath, forKey: "binPath")
		aCoder.encode(varPath, forKey: "varPath")
		aCoder.encode(runAtStartup, forKey: "runAtStartup")
		aCoder.encode(stopAtQuit, forKey: "stopAtQuit")
	}
	
	
	func start(completionHandler: (success: Bool, error: NSError?) -> Void) {
		DispatchQueue.global().async {
			self.busy = true
			
			switch self.dataDirectoryStatus {
				
			case .Empty:
				let result = self.initDatabaseSync()
				if !result.success {
					DispatchQueue.main.async {
						completionHandler(success: result.success, error: result.error)
					}
					return
				}
				break
				
			case .Incompatible:
				print("datadir incomp")
				break
				
			case .Compatible:
				let result = self.startSync()
				if !result.success {
					DispatchQueue.main.async {
						completionHandler(success: result.success, error: result.error!)
					}
					return
				}
				break
				
			}
			
			
			self.busy = false
		}
	}
	
	/*
	- (void)startWithCompletionHandler:(PostgresServerControlCompletionHandler)completionBlock {
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self setIsBusyOnMainThread:YES];
		
		NSError *error = nil;
		PostgresDataDirectoryStatus dataDirStatus = [self statusOfDataDirectory:self.varPath error:&error];
		
		if (dataDirStatus == PostgresDataDirectoryEmpty) {
		BOOL serverDidInit = [self initDatabaseWithError:&error];
		if (!serverDidInit) {
		if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(NO, error); });
		return;
		}
		
		BOOL serverDidStart = [self startServerWithError:&error];
		if (!serverDidStart) {
		if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(NO, error); });
		return;
		}
		
		BOOL createdUser = [self createUserWithError:&error];
		if (!createdUser) {
		if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(NO, error); });
		return;
		}
		
		BOOL createdUserDatabase = [self createUserDatabaseWithError:&error];
		if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(createdUserDatabase, error); });
		}
		else if (dataDirStatus == PostgresDataDirectoryCompatible) {
		BOOL serverDidStart = [self startServerWithError:&error];
		if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(serverDidStart, error); });
		}
		else {
		if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(NO, error); });
		}
		
		[self setIsBusyOnMainThread:NO];
	});
	}
	*/
	
	func stop(completionHandler: (success: Bool, error: NSError) -> Void) {
		
	}
	
	
	private func startSync() -> (success: Bool, error: NSError?) {
		let task = Task()
		task.launchPath = self.binPath.appending("/pg_ctl")
		task.arguments = [
			"start",
			"-D", self.varPath,
			"-w",
			"-l", self.logfilePath,
			"-o", String("-p \(self.port)")
		]
		
		task.standardOutput = Pipe()
		task.standardError = Pipe()
		task.launch()
		let errorDescription = String(data: (task.standardError?.fileHandleForReading.readDataToEndOfFile())!, encoding: .utf8)
		task.waitUntilExit()
		
		var error: NSError?
		if task.terminationStatus != 0 {
			var userInfo: [String: AnyObject] = [:]
			userInfo[NSLocalizedDescriptionKey] = NSLocalizedString("Could not start PostgreSQL server.", comment: "")
			userInfo[NSLocalizedRecoverySuggestionErrorKey] = errorDescription
			userInfo[NSLocalizedRecoveryOptionsErrorKey] = ["OK", "Open Server Log"]
			userInfo[NSRecoveryAttempterErrorKey] = RecoverAttempter()
			userInfo["ServerLogRecoveryOptionIndex"] = (1)
			userInfo["ServerLogPath"] = self.logfilePath
			error = NSError(domain: "com.postgresapp.Postgres.pg_ctl", code: Int(task.terminationStatus), userInfo: userInfo)
		}
		
		if task.terminationStatus == 0 {
			self.running = true
		}
		
		return (task.terminationStatus == 0, error)
	}
	
	
	private func initDatabaseSync() -> (success: Bool, error: NSError) {
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
		let errorDescription = String(data: (task.standardError?.fileHandleForReading.readDataToEndOfFile())!, encoding: .utf8)
		task.waitUntilExit()
		
		var error: NSError!
		if task.terminationStatus != 0 {
			var userInfo: [String: AnyObject] = [:]
			userInfo[NSLocalizedDescriptionKey] = NSLocalizedString("Could not initialize database cluster.", comment: "")
			userInfo[NSLocalizedRecoverySuggestionErrorKey] = errorDescription
			error = NSError(domain: "com.postgresapp.Postgres.initdb", code: Int(task.terminationStatus), userInfo: userInfo)
		}
		
		return (task.terminationStatus == 0, error)
	}
	
}



class RecoverAttempter: NSObject {
	
	override func attemptRecovery(fromError error: NSError, optionIndex recoveryOptionIndex: Int) -> Bool {
		let userInfo = error.userInfo
		let serverLogRecoveryOptionIndex: Int? = Int(String(userInfo["ServerLogRecoveryOptionIndex"]))
		
		if serverLogRecoveryOptionIndex != 0 && recoveryOptionIndex == serverLogRecoveryOptionIndex! {
			NSWorkspace.shared().openFile(String(userInfo["ServerLogPath"]), withApplication: "Console")
		}
		
		return false
	}
	
	
	override func attemptRecovery(fromError error: NSError, optionIndex recoveryOptionIndex: Int, delegate: AnyObject?, didRecoverSelector: Selector?, contextInfo: UnsafeMutablePointer<Void>?) {
		super.attemptRecovery(fromError: error, optionIndex: recoveryOptionIndex, delegate: delegate, didRecoverSelector: didRecoverSelector, contextInfo: contextInfo)
	}
	
}




class DatabaseModel {
	
	var name: String = ""
	
}
