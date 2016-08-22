//
//  BottomBar.swift
//  Postgres
//
//  Created by Chris on 17/08/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class BottomBarSplitViewController: NSSplitViewController {
	
	override func splitView(_ splitView: NSSplitView, effectiveRect proposedEffectiveRect: NSRect, forDrawnRect drawnRect: NSRect, ofDividerAt dividerIndex: Int) -> NSRect {
		return NSZeroRect
	}
	
}



class BottomBarController: NSViewController, MainWindowModelConsumer {
	
	dynamic var mainWindowModel: MainWindowModel!
	
}
