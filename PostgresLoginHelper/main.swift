//
//  main.swift
//  PostgresLoginHelper
//
//  Created by jakob on May 6, 2026
//  This code is released under the terms of the PostgreSQL License.
//

import Cocoa

guard let mainAppURL = Bundle.mainApp?.bundleURL else {
	fatalError("Main app not found")
}

if let bundleIdentifier = Bundle.mainApp?.bundleIdentifier {
	let matchingApplications = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
	guard matchingApplications.isEmpty else {
		print("Main app is already running")
		exit(0)
	}
}

guard OpenURLAsLoginItem(mainAppURL as CFURL) else {
	fatalError("Could not open main app as login item")
}
