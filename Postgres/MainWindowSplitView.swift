//
//  MainWindowSplitView.swift
//  Postgres
//
//  Created by Jakob Egger on 17/06/16.
//
//

import Cocoa

class MainWindowSplitView: NSSplitView {

	override var mouseDownCanMoveWindow : Bool {
		return true
	}
	
}
