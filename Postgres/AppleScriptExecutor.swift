//
//  AppleScriptExecutor.swift
//  Postgres
//
//  Created by Chris on 13/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Foundation

public class AppleScriptExecutor: NSObject {
	private enum Constants {
		static let ASAppleScriptSuite = FourCharCode("ascr")
		static let ASSubroutineEvent  = FourCharCode("psbr")
		static let ASSubroutineName   = FourCharCode("snam")
	}
	
    private let appleScript: NSAppleScript
	
    public init(scriptURL: URL) throws {
        guard FileManager.default.fileExists(atPath: scriptURL.path)             else { throw AppleScriptExecutorError.invalidScriptURL }
        guard let appleScript = NSAppleScript(contentsOf: scriptURL, error: nil) else { throw AppleScriptExecutorError.scriptNotInitialized }
        self.appleScript = appleScript
    }
    
    public convenience init(scriptName: String) throws {
        guard let scriptPath  = Bundle.main.path(forResource: scriptName, ofType: "scpt") else { throw AppleScriptExecutorError.invalidScriptName }
        try self.init(scriptURL: URL(fileURLWithPath: scriptPath))
    }
	
	
    public func runSubroutine(_ subroutine: String, parameters: [String]? = nil) throws {
		let listDescriptor = NSAppleEventDescriptor.list()
		
		if let parameters = parameters {
			for (idx, param) in parameters.enumerated() {
				listDescriptor.insert(NSAppleEventDescriptor(string: param), at: idx+1)
			}
		}
		
		let eventDescriptor = NSAppleEventDescriptor.appleEvent(
			withEventClass:   Constants.ASAppleScriptSuite,
			eventID:          Constants.ASSubroutineEvent,
			targetDescriptor: NSAppleEventDescriptor.null(),
			returnID:         AEReturnID(kAutoGenerateReturnID),
			transactionID:    AETransactionID(kAnyTransactionID)
		)
		eventDescriptor.setDescriptor(NSAppleEventDescriptor(string: subroutine), forKeyword: Constants.ASSubroutineName)
		eventDescriptor.setDescriptor(listDescriptor, forKeyword: keyDirectObject)
		
		var errorDict: NSDictionary?
		appleScript.executeAppleEvent(eventDescriptor, error: &errorDict)
		
		if let errorDict = errorDict {
			throw AppleScriptExecutorError.executionFailed(errorDictionary: errorDict as! [String : Any])
		}
	}
}

public enum AppleScriptExecutorError: CustomNSError, Equatable {
    case invalidScriptURL
	case invalidScriptName
    case scriptNotInitialized
	case executionFailed(errorDictionary: [String : Any])
	
	public var errorUserInfo: [String : Any] {
		let reason: String
		switch self {
        case .invalidScriptURL:
            reason = "Invalid Script URL"
        case .invalidScriptName:
            reason = "Invalid Script Name"
		case .scriptNotInitialized:
			reason = "Script not initialized"
		case .executionFailed(let errorDict):
			print(errorDict)
			let errMsg = errorDict[NSAppleScript.errorMessage] as? String ?? "Unknown Error"
			let errNum = errorDict[NSAppleScript.errorNumber]  as? Int ?? -1
			reason = "\(errMsg) (\(errNum))"
		}
		let description = "Apple Script Error"
		return [NSLocalizedDescriptionKey: description, NSLocalizedRecoverySuggestionErrorKey: reason]
	}
	
	public static func ==(_ lhs: AppleScriptExecutorError, _ rhs: AppleScriptExecutorError) -> Bool {
		switch (lhs, rhs) {
		case (.invalidScriptURL, .invalidScriptURL), (.invalidScriptName, .invalidScriptName), (.scriptNotInitialized, .scriptNotInitialized):
			return true
		case (.executionFailed(let lhsErrDict), .executionFailed(let rhsErrDict)):
			if let lhsErrNum = lhsErrDict[NSAppleScript.errorNumber]  as? Int, let rhsErrNum = rhsErrDict[NSAppleScript.errorNumber]  as? Int {
				return lhsErrNum == rhsErrNum
			}
			fallthrough
		default:
			return false
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
