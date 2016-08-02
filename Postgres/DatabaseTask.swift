//
//  DatabaseTask.swift
//  Postgres
//
//  Created by Chris on 22/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class DatabaseTask: NSObject {
	
	enum ActionStatus {
		case Success
		case Failure(NSError)
	}
	
	private var server: Server
	private var currentTask: Task?
	
	
	init(_ server: Server) {
		self.server = server
	}
	
	
	func dumpDatabase(name: String, to file: String, completionHandler: (_: ActionStatus) -> Void) {
		DispatchQueue.global().async { 
			let dumpRes = self.dumpDatabaseSync(name: name, to: file)
			DispatchQueue.main.async(execute: {
				completionHandler(dumpRes)
			})
		}
	}
	
	
	func restoreDatabase(name: String, from file: String, completionHandler: (_: ActionStatus) -> Void) {
		DispatchQueue.global().async {
			let createRes = self.createDatabaseSync(name: name)
			
			switch createRes {
			case .Failure(_):
				DispatchQueue.main.async {
					completionHandler(createRes)
				}
			case .Success:
				let restoreRes = self.restoreDatabaseSync(name: name, from: file)
				DispatchQueue.main.async {
					completionHandler(restoreRes)
				}
			}
		}
	}
	
	
	func dropDatabase(name: String, completionHandler: (_: ActionStatus) -> Void) {
		DispatchQueue.global().async {
			let dropRes = self.dropDatabaseSync(name: name)
			DispatchQueue.main.async {
				completionHandler(dropRes)
			}
		}
	}
	
	
	func cancel() {
		self.currentTask?.terminate()
		print("DatabaseTask canceled")
	}
	
	
	
	
	/*
	sync handlers
	*/
	private func dumpDatabaseSync(name: String, to file: String) -> ActionStatus {
		let task = Task()
		self.currentTask = task
		task.launchPath = self.server.binPath.appending("/pg_dump")
		task.arguments = [
			"-p", String(self.server.port),
			"-F", "c",
			"-Z", "9",
			"-f", file,
			name
		]
		task.standardOutput = Pipe()
		let errorPipe = Pipe()
		task.standardError = errorPipe
		task.launch()
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		task.waitUntilExit()
		self.currentTask = nil
		
		if task.terminationStatus == 0 {
			return .Success
		} else {
			let userInfo = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not dump database", comment: ""),
				"RawCommandOutput": errorDescription
			]
			let error = NSError(domain: "com.postgresapp.Postgres.pg_dump", code: Int(task.terminationStatus), userInfo: userInfo)
			return .Failure(error)
		}
	}
	
	
	private func createDatabaseSync(name: String) -> ActionStatus {
		let task = Task()
		self.currentTask = task
		task.launchPath = self.server.binPath.appending("/createdb")
		task.arguments = [
			"-p", String(self.server.port),
			name
		]
		task.standardOutput = Pipe()
		let errorPipe = Pipe()
		task.standardError = errorPipe
		task.launch()
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		task.waitUntilExit()
		self.currentTask = nil
		
		if task.terminationStatus == 0 {
			return .Success
		} else {
			let userInfo = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not create database.", comment: ""),
				"RawCommandOutput": errorDescription
			]
			let error = NSError(domain: "com.postgresapp.Postgres.createdb", code: Int(task.terminationStatus), userInfo: userInfo)
			return .Failure(error)
		}
	}
	
	
	private func restoreDatabaseSync(name: String, from file: String) -> ActionStatus {
		let task = Task()
		self.currentTask = task
		task.launchPath = self.server.binPath.appending("/pg_restore")
		task.arguments = [
			"-p", String(self.server.port),
			"-F", "c",
			"-d", name,
			file
		]
		task.standardOutput = Pipe()
		let errorPipe = Pipe()
		task.standardError = errorPipe
		task.launch()
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		task.waitUntilExit()
		self.currentTask = nil
		
		if task.terminationStatus == 0 {
			return .Success
		} else {
			let userInfo = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not restore database.", comment: ""),
				"RawCommandOutput": errorDescription
			]
			let error = NSError(domain: "com.postgresapp.Postgres.pg_restore", code: Int(task.terminationStatus), userInfo: userInfo)
			return .Failure(error)
		}
	}
	
	
	private func dropDatabaseSync(name: String) -> ActionStatus {
		let task = Task()
		self.currentTask = task
		task.launchPath = self.server.binPath.appending("/dropdb")
		task.arguments = [
			"-p", String(self.server.port),
			name
		]
		task.standardOutput = Pipe()
		let errorPipe = Pipe()
		task.standardError = errorPipe
		task.launch()
		let errorDescription = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? "(incorrectly encoded error message)"
		task.waitUntilExit()
		self.currentTask = nil
		
		if task.terminationStatus == 0 {
			return .Success
		} else {
			let userInfo = [
				NSLocalizedDescriptionKey: NSLocalizedString("Could not drop database.", comment: ""),
				"RawCommandOutput": errorDescription
			]
			let error = NSError(domain: "com.postgresapp.Postgres.dropdb", code: Int(task.terminationStatus), userInfo: userInfo)
			return .Failure(error)
		}
	}
	
}
