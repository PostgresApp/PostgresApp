//
//  DatabasesView.swift
//  Postgres
//
//  Created by Chris on 05/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class DatabaseItem: NSCollectionViewItem {
	override var isSelected: Bool {
		didSet {
			if let v = self.view as? DatabaseItemView {
				v.selected = isSelected
			}
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
		if selected {
			let offset = CGFloat(10.0)
			let x = offset
			let y = offset
			let w = frame.width - offset*2
			let h = frame.height - offset*2
			
			let rect = CGRect(x: x, y: y, width: w, height: h)
			let path = NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
			NSColor.selectedControlColor.setFill()
			path.fill()
		}
	}
	
	override func mouseDown(with event: NSEvent) {
		if event.clickCount == 2 {
			NSApp.sendAction(#selector(ServerViewController.openPsql(_:)), to: nil, from: self)
		} else {
			super.mouseDown(with: event)
		}
	}
}
