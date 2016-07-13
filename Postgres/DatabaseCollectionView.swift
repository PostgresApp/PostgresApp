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
			let v = view as? DatabaseItemView
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
		
		/*
		let offset: CGFloat = 10.0
		var f = self.frame
		f.size.width -= offset
		f.size.height -= offset
		f.origin.x += offset/2
		f.origin.y += offset/2
		
		let path = NSBezierPath(roundedRect: f, xRadius: 10, yRadius: 10)
		DispatchQueue.main.sync {
		path.stroke()
		}
		*/
		let offset: CGFloat = CGFloat(10.0)
		let h = frame.height - offset
		let w = frame.width - offset
		let x = frame.origin.x - offset/2
		let y = frame.origin.y - offset/2
		let color = selected ? NSColor.gray() : NSColor.blue()
		
		let drect = CGRect(x: x,y: (h * 0.25),width: (w * 0.5),height: (h * 0.5))
		let path = NSBezierPath(roundedRect: drect, xRadius: 10, yRadius: 10)
		
		color.set()
		path.stroke()
		
	}
	
}
