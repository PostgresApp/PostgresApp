//
//  MainWindowBackgroundView.swift
//  Postgres
//
//  Created by Jakob Egger on 17/06/16.
//
//

import Cocoa

class MainWindowBackgroundView: NSView {

    override func drawRect(dirtyRect: NSRect) {
		NSColor.whiteColor().setFill()
		NSRectFill(dirtyRect)
		
		let imageRect = NSRect(x: 20, y: self.bounds.maxY-20-128, width: 128, height: 128)
		if imageRect.intersects(dirtyRect) {
			NSApp.applicationIconImage.drawInRect(imageRect)
		}
    }
	
	override var mouseDownCanMoveWindow : Bool {
		return true
	}
	
}
