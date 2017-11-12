//
//  AppleScriptExecutorTests.swift
//  PostgresTests
//
//  Created by Chris on 12.11.17.
//  Copyright © 2017 postgresapp. All rights reserved.
//

import XCTest
import Postgres

class AppleScriptExecutorTests: XCTestCase {
	
	func test_invalidScriptURL() {
		let expectedError = AppleScriptExecutorError.invalidScriptURL
		
		XCTAssertThrowsError(
			try AppleScriptExecutor(scriptURL: URL(fileURLWithPath: "invalid"))
		) { error in
			XCTAssertEqual(error as? AppleScriptExecutorError, expectedError)
		}
	}
	
	func test_invalidScriptName() {
		let expectedError = AppleScriptExecutorError.invalidScriptName
		
		XCTAssertThrowsError(
			try AppleScriptExecutor(scriptName: "invalid")
		) { error in
			XCTAssertEqual(error as? AppleScriptExecutorError, expectedError)
		}
	}
	
	func test_executionFailed_runInvalidRoutine() {
		let expectedError = AppleScriptExecutorError.executionFailed(errorDictionary: [NSAppleScript.errorNumber: -1708])
		
		XCTAssertThrowsError(
			try AppleScriptExecutor(scriptName: "PostgresScripts").runSubroutine("invalid")
		) { error in
			XCTAssertEqual(error as? AppleScriptExecutorError, expectedError)
		}
	}
	
	func test_executionFailed_openInvalidApp() {
		let expectedError = AppleScriptExecutorError.executionFailed(errorDictionary: [NSAppleScript.errorNumber: -1728])
		
		XCTAssertThrowsError(
			try AppleScriptExecutor(scriptName: "PostgresScripts").runSubroutine("open_invalidApp")
		) { error in
			XCTAssertEqual(error as? AppleScriptExecutorError, expectedError)
		}
	}
    
}
