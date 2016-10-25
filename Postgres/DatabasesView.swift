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
		let offset = CGFloat(4)
		if selected {
			var inset = CGFloat(0)
			for view in self.subviews where view.identifier == "DBNameLabel" {
				inset = view.frame.minY
			}
			let x = offset
			let y = inset - 10
			let w = frame.width - offset*2
			let h = frame.height - inset + 10
			
			let rect = CGRect(x: x, y: y, width: w, height: h)
			let path = NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
			NSColor.selectedControlColor.setFill()
			path.fill()
		}
		let tf = NSAffineTransform()
		tf.translateX(by: self.bounds.midX-32, yBy: self.bounds.maxY-64-offset*2)
		tf.concat()
		drawDatabase()
	}
	
	private func drawDatabase() {
		let baseColor = NSColor(calibratedRed: 0.714, green: 0.823, blue: 0.873, alpha: 1)
		let frameColor = baseColor.shadow(withLevel: 0.4)
		let fillColor = baseColor.highlight(withLevel: 0.7)
		let lineWidth = CGFloat(1)
		
		frameColor?.setStroke()
		fillColor?.setFill()
		
		for i in 0...3 {
			let y = lineWidth*0.5 + (63.0-lineWidth-8.0) / 3.0 * CGFloat(i)
			
			let oval = NSBezierPath(ovalIn: NSRect(x: lineWidth*0.5, y: y, width: 64-lineWidth, height: 8.0))
			oval.lineWidth = lineWidth
			oval.fill()
			oval.stroke()
			
			if i < 3 {
				let y1 = 4 + lineWidth*0.5 + (63.0-lineWidth-8.0) / 3 * CGFloat(i)
				NSRectFillUsingOperation(NSRect(x: lineWidth*0.5, y: y1, width: 64-lineWidth, height: 16.0), NSCompositingOperation.copy)
			}
		}
		
		frameColor?.setFill()
		NSRectFillUsingOperation(NSRect(x: 0, y: 4+lineWidth*0.5, width: lineWidth, height: 3*(63-lineWidth-8)/3), NSCompositingOperation.copy)
		NSRectFillUsingOperation(NSRect(x: 64-lineWidth, y: 4+lineWidth*0.5, width: lineWidth, height: 3*(63-lineWidth-8)/3), NSCompositingOperation.copy)
	}
	
	override func mouseDown(with event: NSEvent) {
		if event.clickCount == 2 {
			NSApp.sendAction(#selector(ServerViewController.openPsql(_:)), to: nil, from: self)
		} else {
			super.mouseDown(with: event)
		}
	}
}
