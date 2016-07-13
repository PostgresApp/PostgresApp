//
//  ASWrapper.swift
//  Postgres
//
//  Created by Chris on 13/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Foundation

class ASWrapper: NSObject {
	
	func runSubroutine(_ subroutine: String, parameter: String) {
		guard let path = Bundle.main().pathForResource("ASSubroutines", ofType: "scpt") else { return }
		
		// these constants are defined in Carbon (no need to include)
		let kASAppleScriptSuite = self.fourCharCodeFrom("ascr")
		let kASSubroutineEvent = self.fourCharCodeFrom("psbr")
		let keyASSubroutineName = self.fourCharCodeFrom("snam")
		
		var errorDict: NSDictionary?
		
		let script = NSAppleScript(contentsOf: URL(fileURLWithPath: path), error: &errorDict)
		let params = NSAppleEventDescriptor.list()
		params.insert(NSAppleEventDescriptor(string: parameter), at: 1)
		let event = NSAppleEventDescriptor.appleEvent(withEventClass: kASAppleScriptSuite, eventID: kASSubroutineEvent, targetDescriptor: NSAppleEventDescriptor.null(), returnID: AEReturnID(kAutoGenerateReturnID), transactionID: AETransactionID(kAnyTransactionID))
		event.setDescriptor(NSAppleEventDescriptor(string: subroutine), forKeyword: keyASSubroutineName)
		event.setDescriptor(params, forKeyword: keyDirectObject)
		script?.executeAppleEvent(event, error: &errorDict)
		
		if errorDict != nil {
			print(errorDict)
		}
	}
	
	
	private func fourCharCodeFrom(_ string: String) -> FourCharCode {
		assert(string.characters.count == 4, "String length must be 4")
		var result: FourCharCode = 0
		for char in string.utf16 {
			result = (result << 8) + FourCharCode(char)
		}
		return result
	}
	
}
