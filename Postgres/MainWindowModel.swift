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
		guard let selIdx = selectedServerIndices.first else { return nil }
		return serverManager.servers[selIdx]
	}
	
	func removeSelectedServer() {
		guard let selIdx = selectedServerIndices.first else { return }
		serverManager.servers.remove(at: selIdx)
		
		if selIdx > 0 {
			selectedServerIndices = IndexSet(integer: selIdx-1)
		} else {
			selectedServerIndices = IndexSet(integer: 0)
		}
	}
}



protocol MainWindowModelConsumer {
	var mainWindowModel: MainWindowModel! { get set }
}
