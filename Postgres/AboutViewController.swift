//
//  AboutViewController.swift
//  Postgres
// 
// 
// Created by Jakob Egger on 08.09.26.
// This code is released under the terms of the PostgreSQL License.
// 

import Cocoa

class AboutViewController: NSViewController {
	@IBOutlet weak var aboutTextView: NSTextView?
	
	override func viewDidLoad() {
		
		let mutableString = aboutTextView?.textStorage?.mutableString
		
		if let range = mutableString?.range(of: "{{VERSION}}"), range.location != NSNotFound {
			let replacementString =
				(Bundle.main.localizedInfoDictionary?["CFBundleShortVersionString"] as? String) ??
				(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ??
				"unknown Version"
			mutableString?.replaceCharacters(in: range, with: replacementString)
		}
		
		if let range = mutableString?.range(of: "{{BUILD}}"), range.location != NSNotFound {
			let replacementString =
				(Bundle.main.localizedInfoDictionary?[kCFBundleVersionKey as String] as? String) ??
				(Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String) ??
				"unknown Build"
			mutableString?.replaceCharacters(in: range, with: replacementString)
		}

		if let range = mutableString?.range(of: "{{POSTGRESQL_BINARIES}}"), range.location != NSNotFound {
			let replacementString: String
			let binaries = BinaryManager.shared.findAvailableBinaries()
			if binaries.isEmpty {
				replacementString = "none"
			} else {
				let binaryNames = binaries.map { $0.displayName }
				replacementString = binaryNames.joined(separator: ", ")
			}
			mutableString?.replaceCharacters(in: range, with: replacementString)
		}

		super.viewDidLoad()
	}
}
