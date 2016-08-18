//
//  Extensions.swift
//  Postgres
//
//  Created by Chris on 04/08/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Foundation

extension FileManager {
	func applicationSupportDirectoryPath() -> String {
		let url = self.urlsForDirectory(.applicationSupportDirectory, inDomains: .userDomainMask).first!
		let bundleName = Bundle.main().objectForInfoDictionaryKey(kCFBundleNameKey as String) as! String
		let path = try! url.appendingPathComponent(bundleName).path!
		
		if !self.fileExists(atPath: path) {
			try! self.createDirectory(atPath: path, withIntermediateDirectories: false)
		}
		
		return path
	}
}
