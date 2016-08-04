/*

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



class ProgressViewController: NSViewController {
	
	dynamic var statusMessage: String = ""
	dynamic private var animateProgressBar = true
	
	var databaseTask: DatabaseTask?
	
	
	@IBAction func cancel(_ sender: AnyObject?) {
		self.databaseTask?.cancel()
		self.dismiss(self)
	}
	
}



class DatabaseCollectionView: NSCollectionView {
	
	override func rightMouseDown(_ event: NSEvent) {
		let mousePoint = self.convert(event.locationInWindow, from: nil)
		for i in 0..<self.content.count {
			let frame = self.frameForItem(at: i)
			if self.mouse(mousePoint, in: frame) {
				self.selectionIndexes = [i]
				break
			}
		}
		
		super.rightMouseDown(event)
	}
	
	
	override func menu(for event: NSEvent) -> NSMenu? {
		let mousePoint = self.convert(event.locationInWindow, from: nil)
		for i in 0..<self.content.count {
			let frame = self.frameForItem(at: i)
			if self.mouse(mousePoint, in: frame) {
				return self.menu
			}
		}
		return nil
	}
	
}


@IBAction func dumpDatabase(_ sender: AnyObject?) {
	guard let server = self.serverArrayController?.selectedObjects.first as? Server else { return }
	guard let database = self.databaseArrayController?.selectedObjects.first as? Database else { return }
	
	let savePanel = NSSavePanel()
	savePanel.directoryURL = URL(string: "~/Desktop")
	savePanel.nameFieldStringValue = database.name + ".pg_dump"
	savePanel.beginSheetModal(for: self.view.window!) { (result: Int) in
		if result == NSFileHandlingPanelOKButton {
			
			guard let progressViewController = self.storyboard?.instantiateController(withIdentifier: "ProgressView") as? ProgressViewController else { return }
			progressViewController.statusMessage = "Dumping Database..."
			self.presentViewControllerAsSheet(progressViewController)
			
			progressViewController.databaseTask = DatabaseTask(server)
			progressViewController.databaseTask?.dumpDatabase(name: database.name, to: savePanel.url!.path!, completionHandler: { (actionStatus) in
				progressViewController.dismiss(self)
			})
		}
	}
}


@IBAction func restoreDatabase(_ sender: AnyObject?) {
	guard let server = self.serverArrayController?.selectedObjects.first as? Server else { return }
	
	let openPanel = NSOpenPanel()
	openPanel.canChooseFiles = true
	openPanel.canChooseDirectories = false
	openPanel.allowsMultipleSelection = false
	openPanel.resolvesAliases = true
	openPanel.allowedFileTypes = ["pg_dump"]
	openPanel.directoryURL = URL(string: "~/Desktop")
	openPanel.beginSheetModal(for: self.view.window!) { (fileSheetResponse) in
		if fileSheetResponse == NSFileHandlingPanelOKButton {
			
			guard let databaseNameSheetController = self.storyboard?.instantiateController(withIdentifier: "DatabaseNameSheet") as? DatabaseNameSheetController else { return }
			//self.presentViewControllerAsSheet(databaseNameViewController)
			self.view.window!.beginSheet(databaseNameSheetController.window!, completionHandler: { (nameSheetResponse) in
				
				guard let progressViewController = self.storyboard?.instantiateController(withIdentifier: "ProgressView") as? ProgressViewController else { return }
				progressViewController.statusMessage = "Restoring Database..."
				self.presentViewControllerAsSheet(progressViewController)
				
				progressViewController.databaseTask = DatabaseTask(server)
				progressViewController.databaseTask?.restoreDatabase(name: "foo", from: openPanel.url!.path!, completionHandler: { (actionStatus) in
					server.loadDatabases()
					progressViewController.dismiss(self)
				})
				
			})
		}
	}
}


@IBAction func dropDatabase(_ sender: AnyObject?) {
	guard let server = self.serverArrayController?.selectedObjects.first as? Server else { return }
	guard let database = self.databaseArrayController?.selectedObjects.first as? Database else { return }
	
	let alert = NSAlert()
	alert.messageText = "Drop Database?"
	alert.informativeText = "This action can not be undone."
	alert.addButton(withTitle: "Drop Database")
	alert.addButton(withTitle: "Cancel")
	alert.buttons.first?.keyEquivalent = ""
	alert.beginSheetModal(for: self.view.window!) { (modalResponse) in
		if modalResponse == NSAlertFirstButtonReturn {
			
			guard let progressViewController = self.storyboard?.instantiateController(withIdentifier: "ProgressView") as? ProgressViewController else { return }
			progressViewController.statusMessage = "Dropping Database..."
			self.presentViewControllerAsSheet(progressViewController)
			
			progressViewController.databaseTask = DatabaseTask(server)
			progressViewController.databaseTask?.dropDatabase(name: database.name, completionHandler: { (actionStatus) in
				server.loadDatabases()
				progressViewController.dismiss(self)
			})
		}
	}
}
*/
