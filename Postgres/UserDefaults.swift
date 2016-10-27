//
//  UserDefaults.swift
//  Postgres
//
//  Created by Jakob Egger on 27.10.16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

extension UserDefaults {
	// @nonobjc is necessary to prevent the following compiler error (which might be a bug):
	// A declaration cannot be both 'final' and 'dynamic'
	@nonobjc static var shared: UserDefaults = {
		let sharedDefaults = Bundle.main.bundleIdentifier == "com.postgresapp.Postgres2" ? UserDefaults.standard : UserDefaults(suiteName: "com.postgresapp.Postgres2")!
		sharedDefaults.registerPostgresDefaults()
		return sharedDefaults
	}()
	
	func registerPostgresDefaults() {
		self.register(defaults: ["ClientAppName": "Terminal", "StartLoginHelper": true])
	}
}
