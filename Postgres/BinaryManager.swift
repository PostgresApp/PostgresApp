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
	
	let bundledBinaryVersionsURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Versions", isDirectory: true)
    let brewBinaryVersionsURL = URL(fileURLWithPath: "/opt/homebrew/Cellar")
	
    func findAvailableBinaries() -> [PostgresBinary] {
        var versions: [PostgresBinary] = []
        versions.append(contentsOf: self.findAvailableBundledBinaries())
        versions.append(contentsOf: self.findAvailableBrewBinaries())
        return versions
    }
    
	func findAvailableBundledBinaries() -> [PostgresBinary] {
        return findAvailableBinaries(at: bundledBinaryVersionsURL)
	}
    
    func findAvailableBrewBinaries() -> [PostgresBinary] {
        guard let binaryVersionsEnumerator = FileManager().enumerator(
            at: brewBinaryVersionsURL,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]
        ) else {
            return []
        }
        var versions = [PostgresBinary]()
        while let itemURL = binaryVersionsEnumerator.nextObject() as? URL {
            do {
                let resourceValues = try itemURL.resourceValues(forKeys: [.isDirectoryKey])
                guard resourceValues.isDirectory == true else { continue }
            } catch { continue }
            guard itemURL.lastPathComponent.hasPrefix("postgresql@") else {
                continue
            }
            versions.append(contentsOf: findAvailableBinaries(at: itemURL).map { binary in
                var copy = binary
                copy.displayName = "PostgreSQL Brew \(binary.version)"
                return copy
            })
        }
        return versions
    }
    
    private func findAvailableBinaries(at: URL) -> [PostgresBinary] {
        let binaryVersionsEnumerator = FileManager().enumerator(
            at: at,
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
        return PostgresBinary(url: bundledBinaryVersionsURL.appendingPathComponent(latestVersion), version: latestVersion)
	}
	
	func getBinary(for version: String) -> PostgresBinary {
		return PostgresBinary(url: bundledBinaryVersionsURL.appendingPathComponent(version), version: version)
	}
}

struct PostgresBinary {
    var url: URL
	var version: String
	var binPath: String {
		url.appendingPathComponent("bin").path
	}
    var displayName: String
	
    
    init(url: URL, version: String, displayName: String? = nil) {
        self.url = url
        self.version = version
        self.displayName = displayName ?? "PostgreSQL \(version)"
    }
}
