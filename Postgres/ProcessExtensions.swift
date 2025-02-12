//
//  ProcessExtensions.swift
//  Postgres
//
//  Created by Jakob Egger on 27.10.21.
//  Copyright © 2021 postgresapp. All rights reserved.
//

import Foundation

extension Process {
	struct RosettaNeededError: Error, CustomNSError {
		var errorUserInfo: [String : Any] {
			[
				NSLocalizedDescriptionKey: NSLocalizedString("Rosetta not installed", comment: ""),
				NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(
					"""
					Rosetta is needed to run this server. You can install it by running the following command in Terminal:
					
					softwareupdate --install-rosetta
					""",
					comment: ""
				)
			]
		}
	}
	
	func launchAndCheckForRosetta() throws {
		do {
			try self.run()
		}
		catch let error as NSError where error.domain == NSPOSIXErrorDomain && error.code == Int(EBADARCH) && is_arm_mac() {
			throw RosettaNeededError()
		}
	}
}
