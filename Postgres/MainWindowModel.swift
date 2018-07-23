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
        selectedServerIndices = [max(0, selIdx-1)]
	}
}



protocol MainWindowModelConsumer {
	var mainWindowModel: MainWindowModel! { get set }
}
