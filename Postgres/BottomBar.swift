//
//  BottomBar.swift
//  Postgres
//
//  Created by Chris on 17/08/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class BottomBarController: NSViewController, MainWindowModelConsumer {
	
	dynamic var mainWindowModel: MainWindowModel!
	
}



class SidebarButtonImageTransformer: ValueTransformer {
	
	override func transformedValue(_ value: AnyObject?) -> AnyObject? {
		if value as? Bool == true {
			return NSImage(imageLiteralResourceName: NSImageNameLeftFacingTriangleTemplate)
		} else {
			return NSImage(imageLiteralResourceName: NSImageNameRightFacingTriangleTemplate)
		}
	}
	
}
