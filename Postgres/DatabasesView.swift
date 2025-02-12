//
//  DatabasesView.swift
//  Postgres
//
//  Created by Chris on 05/07/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class DatabaseCollectionView: NSCollectionView {
	override var acceptsFirstResponder: Bool {
		if self.numberOfItems(inSection: 0) == 0 {
			return false
		}
		return super.acceptsFirstResponder
	}
	
	override func becomeFirstResponder() -> Bool {
		let didBecomeFirstResponder = super.becomeFirstResponder()
		markSubviewsNeedDisplay()
		return didBecomeFirstResponder
	}
	
	override func resignFirstResponder() -> Bool {
		let didResignFirstResponder = super.resignFirstResponder()
		markSubviewsNeedDisplay()
		return didResignFirstResponder
	}
	
	override func viewWillMove(toWindow newWindow: NSWindow?) {
		if let oldWindow = window {
			NotificationCenter.default.removeObserver(self, name: NSWindow.didBecomeMainNotification, object: oldWindow)
			NotificationCenter.default.removeObserver(self, name: NSWindow.didResignMainNotification, object: oldWindow)
		}
		if let newWindow {
			NotificationCenter.default.addObserver(self, selector: #selector(noteKeyStatusChanged), name: NSWindow.didBecomeMainNotification, object: newWindow)
			NotificationCenter.default.addObserver(self, selector: #selector(noteKeyStatusChanged), name: NSWindow.didResignMainNotification, object: newWindow)
		}
		super.viewWillMove(toWindow: newWindow)
	}
	
	@objc func noteKeyStatusChanged(_ note: NSNotification) {
		markSubviewsNeedDisplay()
	}
	
	func markSubviewsNeedDisplay() {
		var views = subviews
		while let view = views.popLast() {
			view.needsDisplay = true
			views += view.subviews
		}
	}
	
	override func doCommand(by selector: Selector) {
		switch selector {
		case #selector(insertNewline):
			NSApp.sendAction(#selector(ServerViewController.openPsql), to: nil, from: self)
		default:
			return super.doCommand(by: selector)
		}
	}
}

class DatabaseItem: NSCollectionViewItem {
	override var isSelected: Bool {
		didSet {
			if let databaseItemView = self.view as? DatabaseItemView {
				databaseItemView.selected = isSelected
				databaseItemView.needsDisplay = true
			}
		}
	}
}

class DatabaseItemView: NSView {
	var selected = false
	
	override func draw(_ dirtyRect: NSRect) {
		if selected {
			let horizontalPadding = 8.0
			var inset = 0.0
			for view in self.subviews where view.identifier == NSUserInterfaceItemIdentifier("DBNameLabel") {
				inset = view.frame.minY
			}
			let x = horizontalPadding
			let y = inset - 10
			let w = frame.width - horizontalPadding*2
			let h = frame.height - inset + 10
			
			let rect = CGRect(x: x, y: y, width: w, height: h)
			let path = NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
			if
				let collectionView = self.enclosingScrollView?.documentView as? NSCollectionView,
				collectionView.isFirstResponder,
				collectionView.window?.isMainWindow == true
			{
				NSColor.selectedControlColor.setFill()
			} else {
				NSColor.unemphasizedSelectedTextBackgroundColor.withAlphaComponent(0.8).setFill()
			}
			path.fill()
		}
		let offset = 4.0
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
				NSRect(x: lineWidth*0.5, y: y1, width: 64-lineWidth, height: 16.0).fill(using: .copy)
			}
		}
		
		frameColor?.setFill()
		NSRect(x: 0, y: 4+lineWidth*0.5, width: lineWidth, height: 3*(63-lineWidth-8)/3).fill(using: .copy)
		NSRect(x: 64-lineWidth, y: 4+lineWidth*0.5, width: lineWidth, height: 3*(63-lineWidth-8)/3).fill(using: .copy)
	}
	
	override func mouseDown(with event: NSEvent) {
		if event.clickCount == 2 {
			NSApp.sendAction(#selector(ServerViewController.openPsql(_:)), to: nil, from: self)
		} else {
			super.mouseDown(with: event)
		}
	}
}
