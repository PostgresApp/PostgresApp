//
//  BinaryManager.swift
//  Postgres
//
//  Created by Jakob Egger on 22.12.22.
//  Copyright © 2022 postgresapp. All rights reserved.
//

import Foundation

class BinaryManager {
	static let shared = BinaryManager()
	
	func findAvailableBinaries() -> [PostgresBinary] {
		var allAppURLs = otherAppCopyURLs
		if let mainAppIndex = otherAppCopyURLs.firstIndex(of: Bundle.main.bundleURL) {
			allAppURLs.remove(at: mainAppIndex)
		}
		allAppURLs.insert(Bundle.main.bundleURL, at: 0)
		var versions = [PostgresBinary]()
		for appURL in allAppURLs {
			let binaryVersionsEnumerator = FileManager().enumerator(
				at: appURL.appendingPathComponent("Contents/Versions", isDirectory: true),
				includingPropertiesForKeys: [.isDirectoryKey],
				options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]
			)!
			while let itemURL = binaryVersionsEnumerator.nextObject() as? URL {
				do {
					let resourceValues = try itemURL.resourceValues(forKeys: [.isDirectoryKey])
					guard resourceValues.isDirectory == true else { continue }
				} catch { continue }
				let folderName = itemURL.lastPathComponent
				let displayName = allAppURLs.count == 1 ? nil : "PostgreSQL \(folderName) – \(appURL.path.replacingOccurrences(of:"/Users/\(NSUserName())", with: "~"))"
				versions.append(
					PostgresBinary(url: itemURL, version: folderName, appURL: appURL)
				)
			}
		}
		versions.sort { (a, b) -> Bool in
			var comparisonResult = a.url.path.compare(b.url.path, options:[.numeric])
			if comparisonResult == .orderedSame {
				comparisonResult = a.version.compare(b.version, options:[.numeric])
			}
			return comparisonResult == .orderedAscending
		}
		return versions
	}
	
	func getLatestBinary() -> PostgresBinary {
		let latestVersion = Bundle.main.object(forInfoDictionaryKey: "LatestStablePostgresVersion") as! String
		return PostgresBinary(url: Bundle.main.bundleURL.appendingPathComponent("Contents/Versions", isDirectory: true).appendingPathComponent(latestVersion, isDirectory: true), version: latestVersion, appURL: Bundle.main.bundleURL)
	}
	
	func getBinary(for version: String) -> PostgresBinary {
		return PostgresBinary(url: Bundle.main.bundleURL.appendingPathComponent("Contents/Versions", isDirectory: true).appendingPathComponent(version, isDirectory: true), version: version,
							  appURL: Bundle.main.bundleURL)
	}
	
	var otherAppCopiesQuery = NSMetadataQuery()
	
	func startSearchingOtherAppCopies() {
		let predicate = NSPredicate(format: "kMDItemCFBundleIdentifier == 'com.postgresapp.Postgres2'")
		otherAppCopiesQuery.predicate = predicate
		otherAppCopiesQuery.start()
	}
	
	var otherAppCopyURLs: [URL] {
		let results = otherAppCopiesQuery.results as! [NSMetadataItem]
		var urls = [URL]()
		for result in results {
			guard let path = result.value(forAttribute: NSMetadataItemPathKey) as? String else {
				print("NSMetadataItem is missing NSMetadataItemPathKey")
				continue
			}
			urls.append(URL(fileURLWithPath: path))
		}
		return urls
	}
}

struct PostgresBinary: Equatable {
	var url: URL
	var version: String
	var displayName: String
	var appURL: URL?
	init(url: URL, version: String, appURL: URL, displayName: String? = nil) {
		self.url = url
		self.version = version
		self.displayName = displayName ?? "PostgreSQL \(version)"
		self.appURL = appURL
	}
	var binPath: String {
		url.appendingPathComponent("bin").path
	}
	static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.url == rhs.url
	}
}
