//
//  DatabaseCollectionView.swift
//  Postgres
//
//  Created by Chris on 05/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class DatabaseCollectionView: NSCollectionView {
	
	override func rightMouseDown(_ event: NSEvent) {
		let mousePoint = self.convert(event.locationInWindow, from: nil)
		for i in 0..<self.content.count {
			let frame = self.frameForItem(at: i)
			if self.mouse(mousePoint, in: frame) {
				self.selectionIndexes = [i]
				break
			}
		}
		
		super.rightMouseDown(event)
	}
	
	
	override func menu(for event: NSEvent) -> NSMenu? {
		let mousePoint = self.convert(event.locationInWindow, from: nil)
		for i in 0..<self.content.count {
			let frame = self.frameForItem(at: i)
			if self.mouse(mousePoint, in: frame) {
				return self.menu
			}
		}
		return nil
	}
	
}



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
		if self.selected {
			let offset = CGFloat(10.0)
			let x = offset
			let y = offset
			let w = frame.width - offset*2
			let h = frame.height - offset*2
			
			let rect = CGRect(x: x, y: y, width: w, height: h)
			let path = NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
			NSColor.selectedControlColor().setFill()
			path.fill()
		}
	}
	
	
	override func mouseDown(_ event: NSEvent) {
		if event.clickCount == 2 {
			NSApp.sendAction(#selector(MainViewController.openPsql(_:)), to: nil, from: self)
		} else {
			super.mouseDown(event)
		}
	}
	
	
}
