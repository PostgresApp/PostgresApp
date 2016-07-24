//
//  ProgressViewController.swift
//  Postgres
//
//  Created by Chris on 23/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class ProgressViewController: NSViewController {
	
	dynamic var statusMessage: String = ""
	dynamic private var animateProgressBar = true
	
	var databaseTask: DatabaseTask?
	
	
	@IBAction func cancel(_ sender: AnyObject?) {
		self.databaseTask?.cancel()
		self.dismiss(self)
	}
	
}
