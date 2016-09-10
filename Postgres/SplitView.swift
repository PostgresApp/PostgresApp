//
//  SplitView.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController, MainWindowModelConsumer {
	
	dynamic var mainWindowModel: MainWindowModel!
	var modelObserver: KeyValueObserver!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		modelObserver = self.observe("mainWindowModel.sidebarVisible") { [weak self] _ in
			guard let this = self, this.mainWindowModel != nil else { return }
			this.toggleSidebar(nil)
		}
	}
	
	
	
	
}
