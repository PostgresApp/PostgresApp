//
//  Extensions.swift
//  Postgres
//
//  Created by Chris on 04/08/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Foundation

extension FileManager {
	func applicationSupportDirectoryPath(createIfNotExists: Bool) -> String? {
		guard let url = self.urlsForDirectory(.applicationSupportDirectory, inDomains: .userDomainMask).first else { return nil }
		let bundleName = Bundle.main().objectForInfoDictionaryKey(kCFBundleNameKey as String) as! String
		let path = try! url.appendingPathComponent(bundleName).path!
		
		if !self.fileExists(atPath: path) && createIfNotExists {
			do {
				try self.createDirectory(atPath: path, withIntermediateDirectories: false)
			}
			catch {
				return nil
			}
		}
		
		return path
	}
}
