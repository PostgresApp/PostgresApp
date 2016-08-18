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
}



protocol MainWindowModelConsumer {
	var mainWindowModel: MainWindowModel! { get set }
}
