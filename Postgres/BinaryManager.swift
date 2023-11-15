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
	
	let binaryVersionsURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Versions", isDirectory: true)
	
	func findAvailableBinaries() -> [PostgresBinary] {
		let binaryVersionsEnumerator = FileManager().enumerator(
			at: binaryVersionsURL,
			includingPropertiesForKeys: [.isDirectoryKey],
			options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]
		)!
		var versions = [PostgresBinary]()
		while let itemURL = binaryVersionsEnumerator.nextObject() as? URL {
			do {
				let resourceValues = try itemURL.resourceValues(forKeys: [.isDirectoryKey])
				guard resourceValues.isDirectory == true else { continue }
			} catch { continue }
			let folderName = itemURL.lastPathComponent
			versions.append(
				PostgresBinary(url: itemURL, version: folderName)
			)
		}
		versions.sort { (a, b) -> Bool in
			return a.version.compare(b.version, options:[.numeric]) == .orderedAscending
		}
		return versions
	}
	
	func getLatestBinary() -> PostgresBinary? {
		let latestVersion = Bundle.main.object(forInfoDictionaryKey: "LatestStablePostgresVersion") as? String
		guard let latestVersion, !latestVersion.isEmpty else { return nil }
		return PostgresBinary(url: binaryVersionsURL.appendingPathComponent(latestVersion), version: latestVersion)
	}
	
	func getBinary(for version: String) -> PostgresBinary {
		return PostgresBinary(url: binaryVersionsURL.appendingPathComponent(version), version: version)
	}
}

struct PostgresBinary {
	var url: URL
	var version: String
	var binPath: String {
		url.appendingPathComponent("bin").path
	}
	var displayName: String {
		"PostgreSQL \(version)"
	}
}
