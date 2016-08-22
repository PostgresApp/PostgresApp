//
//  MainWindowModel.swift
//  Postgres
//
//  Created by Chris on 17/08/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Cocoa

class MainWindowModel: NSObject {
	dynamic var serverManager = ServerManager.shared
	dynamic var selectedServerIndices = IndexSet()
	dynamic var sidebarVisible = false
	
	var firstSelectedServer: Server? {
		guard let firstIndex = selectedServerIndices.first else { return nil }
		return serverManager.servers[firstIndex]
	}
}



protocol MainWindowModelConsumer {
	var mainWindowModel: MainWindowModel! { get set }
}
