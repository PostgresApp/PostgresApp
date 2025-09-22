//
//  CrashLogCollector.swift
//  Postgres
//
//  Created by dev on 04.06.25.
//  Copyright © 2025 postgresapp. All rights reserved.
//

import Foundation
import AppKit

class CrashLogCollector: NSObject, URLSessionDataDelegate {
	static var shared = CrashLogCollector()
	
	func scanInBackground() {
		Task.detached {
			self.scan()
		}
	}
	var newCrashes = [(filename: String, crashReport: String)]()
	var uploadErrors = [(filename: String, errorDescription: String)]()
	private func scan() {
		let fileManager = FileManager()
		var crashReportURLs = [URL]()
		let diagnosticReportsDirectories = [
			URL(fileURLWithPath: NSHomeDirectory()+"/Library/Logs/DiagnosticReports"),
			URL(fileURLWithPath: "/Library/Logs/DiagnosticReports")
		]
		for diagnosticReportsDirectory in diagnosticReportsDirectories {
			guard let enumerator = fileManager.enumerator(at: diagnosticReportsDirectory, includingPropertiesForKeys: [.isDirectoryKey]) else {
				print("Could not enumerate crash log directory \(diagnosticReportsDirectory)")
				continue
			}
			for case let url as URL in enumerator {
				crashReportURLs.append(url)
			}
		}
		var processedFiles = UserDefaults.standard.stringArray(forKey: "ProcessedCrashFiles") ?? []
		for url in crashReportURLs {
			if let isDirectory = try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory, isDirectory == true { continue }
			if url.pathExtension == "diag" {
				// These are diagnostic logs that are written sometimes by macOS
				// For example, a '.diag' log file is created when Sparkle extracts the update from the DMG
				// We don't want to upload these log files since we don't need them
				continue
			}
			let filename = url.lastPathComponent
			if processedFiles.contains(filename) { continue }
			if filename.hasPrefix("Postgres") || filename.hasPrefix("postgres") || filename.hasPrefix("psql") {
				do {
					let crashReport = try String(contentsOf: url, encoding: .utf8)
					// We want to make sure we only upload crash reports from Postgres.app
					// Not from other PostgreSQL distributions like Homebrew or EnterpriseDB
					//  - the "com.postgresapp" substring should match either code signing identifier, bundle identifier or the "app coalition identifier"
					//    (code signing identifier is not included on older versions of macOS, bundle identifier and app coalition are missing when processes are started from Terminal)
					//  - "Postgres.app" would match the process path (might not catch cases where app is translocated or renamed by user)
					// It is still possible that we miss some of our crash reports, but it's very unlikely that we upload crash reports from other distributions
					if crashReport.range(of: "com.postgresapp") == nil && crashReport.range(of: "Postgres.app") == nil
					{
						// Probably not from Postgres.app
						// Add it to processed files so we don't read it again
						processedFiles.append(filename)
						UserDefaults.standard.setValue(processedFiles, forKey: "ProcessedCrashFiles")
						continue
					}
					newCrashes.append((filename: filename, crashReport: crashReport))
				}
				catch {
					print("Could not read crash report \(filename)")
				}
			}
		}
		if !newCrashes.isEmpty {
			let newCrashes = newCrashes
			Task { @MainActor in
				let alert = NSAlert()
				alert.messageText = newCrashes.count==1 ? "New crash report found" : "\(newCrashes.count) new crash reports found"
				alert.informativeText = "Postgres.app can automatically send crash reports to the maintainers. Crash reports contain anonymized data about application crashes and are essential for fixing problems in the app."
				alert.addButton(withTitle: newCrashes.count==1 ? "Send Crash Report" : "Send Crash Reports")
				alert.addButton(withTitle: "Ignore")
				var mainWindow: NSWindow?
				for window in NSApplication.shared.windows {
					if window.windowController is MainWindowController {
						mainWindow = window
					}
				}
				guard let mainWindow else {
					print("Found crashes but did not find main window")
					return
				}
				alert.beginSheetModal(for: mainWindow) { response in
					if response == .alertFirstButtonReturn {
						// transmit crashes
						for (filename, crashData) in newCrashes {
							var request = URLRequest(url: URL(string: "https://crashreporting.postgresapp.com/upload")!)
							request.httpMethod = "POST"
							request.httpBody = crashData.data(using: .utf8)
							let postTask = self.session.dataTask(with: request) { _, response, error in
								if let error {
									self.uploadFailed(filename: filename, errorDescription: "failed to transmit crash \(filename): \(error)")
									return
								}
								if let httpResponse = response as? HTTPURLResponse {
									if httpResponse.statusCode == 200 {
										self.uploadFinished(filename: filename)
									} else {
										self.uploadFailed(filename: filename, errorDescription: "failed to transmit crash \(filename): HTTP \(httpResponse.statusCode)")
									}
								} else {
									self.uploadFailed(filename: filename, errorDescription: "failed to transmit crash \(filename): Unexpected response: \(response?.className ?? "nil")")
								}
							}
							postTask.resume()
						}
					} else {
						var processedFiles = UserDefaults.standard.stringArray(forKey: "ProcessedCrashFiles") ?? []
						for (name, _) in newCrashes {
							processedFiles.append(name)
						}
						UserDefaults.standard.setValue(processedFiles, forKey: "ProcessedCrashFiles")
					}
				}
			}
		}
	}
	lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
	func uploadFinished(filename: String) {
		Task { @MainActor in
			print("Transmitted crash \(filename)")
			var processedFiles = UserDefaults.standard.stringArray(forKey: "ProcessedCrashFiles") ?? []
			processedFiles.append(filename)
			UserDefaults.standard.setValue(processedFiles, forKey: "ProcessedCrashFiles")
			newCrashes.removeAll { $0.filename == filename }
			if newCrashes.isEmpty { reportErrors() }
		}
	}
	func uploadFailed(filename: String, errorDescription: String) {
		Task { @MainActor in
			print("Failed to transmit crash \(filename)")
			uploadErrors.append((filename: filename, errorDescription: errorDescription))
			newCrashes.removeAll { $0.filename == filename }
			if newCrashes.isEmpty { reportErrors() }
		}
	}
	@MainActor func reportErrors() {
		if uploadErrors.isEmpty {
			print("All crashes transmitted successfully")
			return
		}
		let alert = NSAlert()
		alert.messageText = uploadErrors.count == 1 ? "Could not send crash report" : "Could not send \(uploadErrors.count) crash reports"
		var informativeText = ""
		for (index, uploadError) in uploadErrors.enumerated() {
			if index > 2 && uploadErrors.count > 4 {
				informativeText += "(and \(uploadErrors.count-index) more errors)\n"
				break
			}
			informativeText += uploadError.errorDescription
			informativeText += "\n"
		}
		informativeText.removeLast()
		alert.informativeText = informativeText
		var mainWindow: NSWindow?
		for window in NSApplication.shared.windows {
			if window.windowController is MainWindowController {
				mainWindow = window
			}
		}
		guard let mainWindow else {
			print("Tried to report errors but did not find main window:\n\(alert.informativeText)")
			return
		}
		alert.beginSheetModal(for: mainWindow)
	}
}
