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

guard OpenURLAsLoginItem(mainAppURL as CFURL) else {
	fatalError("Could not open main app as login item")
}
