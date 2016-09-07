//
//  ClientLauncher.swift
//  Postgres
//
//  Created by Chris on 13/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Foundation

class ClientLauncher: NSObject {
	
	private let scriptPath = "ClientLauncher"
	
	
	func runSubroutine(_ subroutine: String, parameters: [String]?) throws {
		guard let path = Bundle.main.path(forResource: scriptPath, ofType: "scpt") else { return }
		
		// these constants are defined in Carbon (no need to include)
		let kASAppleScriptSuite = FourCharCode("ascr")
		let kASSubroutineEvent = FourCharCode("psbr")
		let keyASSubroutineName = FourCharCode("snam")
		
		var errorDict: NSDictionary?
		
		let script = NSAppleScript(contentsOf: URL(fileURLWithPath: path), error: &errorDict)
		let paramDescr = NSAppleEventDescriptor.list()
		
		if let parameters = parameters {
			var idx = 1
			for p in parameters {
				paramDescr.insert(NSAppleEventDescriptor(string: p), at: idx)
				idx += 1
			}
		}
		
		let eventDescr = NSAppleEventDescriptor.appleEvent(withEventClass: kASAppleScriptSuite, eventID: kASSubroutineEvent, targetDescriptor: NSAppleEventDescriptor.null(), returnID: AEReturnID(kAutoGenerateReturnID), transactionID: AETransactionID(kAnyTransactionID))
		eventDescr.setDescriptor(NSAppleEventDescriptor(string: subroutine), forKeyword: keyASSubroutineName)
		eventDescr.setDescriptor(paramDescr, forKeyword: keyDirectObject)
		script?.executeAppleEvent(eventDescr, error: &errorDict)
		
		if let errorDict = errorDict {
			throw NSError(domain: "com.postgresapp.Postgres2.ClientLauncher", code: 0, userInfo: (errorDict as! [NSObject: AnyObject]))
		}
	}
}


private extension FourCharCode {
	init(_ string: String) {
		self = 0
		for char in string.utf16 {
			self = (self << 8) + FourCharCode(char)
		}
	}
}
