//
//  ScannerExtensions.swift
//  Postgres
//
//  Created by Jakob Egger on 06.06.23.
//  Copyright © 2023 postgresapp. All rights reserved.
//

import Foundation

extension Scanner {
	func scanConfigParameterValue() -> String? {
		
		// first scan quoted values
		if scanString("'", into: nil) {
			var val = ""
			while true {
				var str: NSString?
				if scanUpTo("'", into: &str) {
					val += str! as String
				}
				if scanString("''", into: nil) {
					continue
				}
				scanString("'", into: nil)
				break
			}
			return val
		}
		
		// if no quotes, scan unquoted stuff
		var ustr: NSString?
		if scanUpTo("#", into: &ustr) {
			return ustr! as String
		}
		
		return nil
	}
}
