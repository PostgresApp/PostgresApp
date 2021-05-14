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
		let url = self.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
		
		let bundleName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
		let path = url.appendingPathComponent(bundleName).path
		
		if !self.fileExists(atPath: path) {
			try! self.createDirectory(atPath: path, withIntermediateDirectories: false)
		}
		
		return path
	}
	
	func applicationExists(_ appName: String) -> Bool {
		var appPath = "/Applications/"
		switch appName {
		case "Terminal":
			appPath += "Utilities/"+appName+".app"
		default:
			appPath += appName+".app"
		}
		return self.fileExists(atPath: appPath)
	}
}
