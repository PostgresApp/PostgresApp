//
//  ClientLauncher.swift
//  Postgres
//
//  Created by Chris on 13/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Foundation

class ClientLauncher: NSObject {
	
	func runSubroutine(_ subroutine: String, parameters: [String]?) throws {
		guard let path = Bundle.main.path(forResource: "ClientLauncher", ofType: "scpt") else { return }
		
		let kASAppleScriptSuite = FourCharCode("ascr")
		let kASSubroutineEvent  = FourCharCode("psbr")
		let keyASSubroutineName = FourCharCode("snam")
		
		var errorDict: NSDictionary?
		let script = NSAppleScript(contentsOf: URL(fileURLWithPath: path), error: &errorDict)
		let paramDescr = NSAppleEventDescriptor.list()
		if let parameters = parameters {
			for (index, param) in parameters.enumerated() {
				paramDescr.insert(NSAppleEventDescriptor(string: param), at: index+1)
			}
		}
		
		let eventDescr = NSAppleEventDescriptor.appleEvent(withEventClass: kASAppleScriptSuite, eventID: kASSubroutineEvent, targetDescriptor: .null(), returnID: AEReturnID(kAutoGenerateReturnID), transactionID: AETransactionID(kAnyTransactionID))
		eventDescr.setDescriptor(NSAppleEventDescriptor(string: subroutine), forKeyword: keyASSubroutineName)
		eventDescr.setDescriptor(paramDescr, forKeyword: keyDirectObject)
		script?.executeAppleEvent(eventDescr, error: &errorDict)
		
		if let errorDict = errorDict as? [String : Any] {
			let userInfo = [
				NSLocalizedDescriptionKey: "Error launching Application",
				NSLocalizedRecoverySuggestionErrorKey: errorDict[NSAppleScript.errorMessage] ?? "Unknown NSAppleScriptError"
			]
			throw NSError(domain: "com.postgresapp.Postgres2.ClientLauncher", code: 0, userInfo: userInfo)
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
