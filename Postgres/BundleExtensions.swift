//
//  BundleExtensions.swift
//  Postgres
//
//  Created by Jakob Egger on 25.09.23.
//  Copyright © 2023 postgresapp. All rights reserved.
//

import Foundation

extension Bundle {
	static var mainApp: Bundle? {
		if Bundle.main.bundleIdentifier == "com.postgresapp.Postgres2" {
			return Bundle.main
		} else {
			var containingBundleURL = Bundle.main.bundleURL
			repeat {
				containingBundleURL.deleteLastPathComponent()
			} while containingBundleURL.pathComponents.count > 1 &&  containingBundleURL.pathExtension != "app"
			if let containingBundle = Bundle(url: containingBundleURL) {
				return containingBundle
			}
		}
		return nil
	}
}
