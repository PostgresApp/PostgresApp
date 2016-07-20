//
//  ASWrapper.swift
//  Postgres
//
//  Created by Chris on 13/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Foundation

class ASWrapper: NSObject {
	
	func runSubroutine(_ subroutine: String, parameters: [String]?) throws {
		guard let path = Bundle.main().pathForResource("ASSubroutines", ofType: "scpt") else { return }
		
		// these constants are defined in Carbon (no need to include)
		let kASAppleScriptSuite = self.fourCharCodeFrom("ascr")
		let kASSubroutineEvent = self.fourCharCodeFrom("psbr")
		let keyASSubroutineName = self.fourCharCodeFrom("snam")
		
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
			throw NSError(domain: "com.postgresapp.Postgres.ASWrapper", code: 0, userInfo: (errorDict as! [NSObject: AnyObject]))
		}
	}
	
	
	private func fourCharCodeFrom(_ string: String) -> FourCharCode {
		assert(string.characters.count == 4, "\(self.className+"."+#function): Parameter must consist of 4 characters")
		var result: FourCharCode = 0
		for char in string.utf16 {
			result = (result << 8) + FourCharCode(char)
		}
		return result
	}
	
}
