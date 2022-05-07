//
//  InstallHistory.swift
//  macOS Install History
//
//  Created by Jakob Egger on 06.05.22.
//

import Foundation

class InstallHistory {
	
	static let defaultURL = URL(fileURLWithPath:"/Library/Receipts/InstallHistory.plist")
	
	static func forCurrentMachine() throws -> InstallHistory {
		return try InstallHistory(url: defaultURL)
	}
	
	static var local = try? forCurrentMachine()
	
	let url: URL
	
	init(url: URL) throws {
		self.url = url
		let data = try Data(contentsOf: url)
		let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
		guard let historyElements = plist as? [[String:Any]] else {
			throw InstallHistoryError(errorDescription: "The property does not have the expected shape.")
		}
		records = try Self.parseHistory(elements: historyElements)
	}
	
	struct InstallRecord {
		var displayName: String
		var displayVersion: String
		var installDate: Date
	}

	var records = [InstallRecord]()
	
	struct InstallHistoryError: LocalizedError {
		var errorDescription: String
	}
	
	static func parseHistory(elements: [[String:Any]]) throws -> [InstallRecord] {
		try elements.compactMap { (element: [String : Any]) in
			let packageIdentifiers: [String] = element["packageIdentifiers"] as? [String] ?? []
			if packageIdentifiers == [] || packageIdentifiers.contains("com.apple.pkg.macOSBrain") {
				// probably a macOS update!
				guard let date = element["date"] as? Date else {
					throw InstallHistoryError(errorDescription: "The history element has an invalid date: \(element)")
				}
				guard let displayName = element["displayName"] as? String else {
					throw InstallHistoryError(errorDescription: "The history element has an invalid displayName: \(element)")
				}
				guard let displayVersion = element["displayVersion"] as? String else {
					throw InstallHistoryError(errorDescription: "The history element has an invalid displayVersion: \(element)")
				}
				var cleanedDisplayVersion = displayVersion.trimmingCharacters(in: .whitespaces)
				if cleanedDisplayVersion.isEmpty {
					if let range = displayName.range(of: "(\\d{2})(\\.\\d+){1,2}", options: .regularExpression, range: nil, locale: nil) {
						cleanedDisplayVersion = String(displayName[range])
					} else {
						return nil
					}
				}
				return InstallRecord(displayName: displayName, displayVersion: cleanedDisplayVersion, installDate: date)
			} else {
				// some other software
				return nil
			}
		}
	}
	
	func firstConfirmedSighting(version: String) -> Date? {
		var firstSighting: Date?
		for record in records {
			let compRes = version.compare(record.displayVersion, options: .numeric, range: nil, locale: nil)
			if compRes == .orderedSame || compRes == .orderedAscending {
				if firstSighting == nil || record.installDate < firstSighting! {
					firstSighting = record.installDate
				}
			}
		}
		return firstSighting
	}
	
	func macOSVersion(on checkDate: Date) -> String? {
		var latestRecord: InstallRecord?
		for record in records {
			if record.installDate < checkDate {
				if latestRecord == nil || latestRecord!.installDate < record.installDate {
					latestRecord = record
				}
			}
		}
		return latestRecord?.displayVersion
	}

}

