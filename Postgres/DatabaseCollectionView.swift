//
//  DatabaseController.swift
//  Postgres
//
//  Created by Chris on 05/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa


class DatabaseItem: NSCollectionViewItem {
	override var isSelected: Bool {
		didSet {
			let v = self.view as? DatabaseItemView
			v?.selected = isSelected
		}
	}
}


class DatabaseItemView: NSView {
	dynamic var selected: Bool = false {
		didSet {
			self.needsDisplay = true
		}
	}
	
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		let offset = CGFloat(10.0)
		let x = offset
		let y = offset
		let w = frame.width - offset*2
		let h = frame.height - offset*2
		
		let rect = CGRect(x: x, y: y, width: w, height: h)
		let path = NSBezierPath(roundedRect: rect, xRadius: 10, yRadius: 10)
		
		(self.selected ? .blue() : .lightGray() as NSColor).setStroke()
		path.stroke()
	}
	
	
	
	override func mouseDown(_ event: NSEvent) {
		super.mouseDown(event)
		
		if event.clickCount == 2 {
			NSApp.sendAction(#selector(MainViewController.openPsql(_:)), to: nil, from: self)
		}
	}
	
	
	override func rightMouseDown(_ event: NSEvent) {
		super.rightMouseDown(event)
		
		guard let m = self.menu else {
			Swift.print("\(self.className): IBOutlet menu is nil")
			return
		}
		NSMenu.popUpContextMenu(m, with: event, for: self)
	}
	
	
	@IBAction func contextMenuAction(_ sender: AnyObject?) {
		Swift.print("contextMenuAction")
	}
}
