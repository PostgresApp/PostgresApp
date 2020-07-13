//
//  DnDArrayController.swift
//  Postgres
//
//  Created by Chris on 18/10/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//
//  Inspired by https://github.com/yconst/YCHarness/blob/master/RSRTVArrayController.m

import Cocoa

class DnDArrayController: NSArrayController, NSTableViewDataSource, NSTableViewDelegate {
	
	let draggingEnabled = true
	let draggedType = "com.chrispysoft.DnDArrayController.draggedType"
	
	@IBOutlet var tableView: NSTableView!
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		// awakeFromNib() should only be called after tableView has been set.
		// However, this is not true on macOS 10.10: awakeFromNib() is called multiple times, including before tableView is set.
		// To avoid a crash, we can't implicitly force unwrap tableView
		tableView?.registerForDraggedTypes(convertToNSPasteboardPasteboardTypeArray([draggedType]))
	}
	
	
	func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
		if draggingEnabled {
			let rowData = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
			pboard.declareTypes(convertToNSPasteboardPasteboardTypeArray([draggedType]), owner: self)
			pboard.setData(rowData, forType: convertToNSPasteboardPasteboardType(draggedType))
		}
		return draggingEnabled
	}
	
	func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
		guard dropOperation == .above else {
			return []
		}
		guard info.draggingSource as? NSTableView == tableView else {
			return []
		}
		
		return .move
	}
	
	func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
		guard info.draggingSource as? NSTableView == tableView, let rowData = info.draggingPasteboard.data(forType: convertToNSPasteboardPasteboardType(draggedType)), let indexes = NSKeyedUnarchiver.unarchiveObject(with: rowData) as? IndexSet else {
			return false
		}
		
		moveArrangedObjects(from: indexes, to: row)
		
		var targetRow = row
		for index in indexes where index < row {
			targetRow -= 1
		}
		let selectedIndexes = IndexSet( targetRow ..< targetRow + indexes.count )
		self.setSelectionIndexes(selectedIndexes)
		
		ServerManager.shared.saveServers()
		
		return true
	}
	
	
	private func moveArrangedObjects(from indexes: IndexSet, to index: Int) {
		var objects = self.arrangedObjects as! [AnyObject]
		var object: Any!
		var aboveInsertIdxCnt = 0
		var removeIdx: Int!
		var localIdx = index
		
		for currIdx in indexes {
			if currIdx >= localIdx {
				removeIdx = currIdx + aboveInsertIdxCnt
				aboveInsertIdxCnt = aboveInsertIdxCnt+1
			} else {
				removeIdx = currIdx
				localIdx = localIdx-1
			}
			
			object = objects[removeIdx]
			
			self.remove(atArrangedObjectIndex: removeIdx)
			self.insert(object, atArrangedObjectIndex: localIdx)
		}
	}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardTypeArray(_ input: [String]) -> [NSPasteboard.PasteboardType] {
	return input.map { key in NSPasteboard.PasteboardType(key) }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardType(_ input: String) -> NSPasteboard.PasteboardType {
	return NSPasteboard.PasteboardType(rawValue: input)
}
