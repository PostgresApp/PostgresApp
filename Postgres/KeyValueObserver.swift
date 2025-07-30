//
//  KeyValueObserver.swift
//  Postgres
//
//  Created by Chris on 19/08/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Foundation

class KeyValueObserver: NSObject {
	
	typealias KVOCallback = ([NSKeyValueChangeKey: Any]?) -> Void
	
	let keyPath: String
	private let callback: KVOCallback
	
	init(_ keyPath: String, _ callback: @escaping KVOCallback, _ object: NSObject) {
		self.keyPath = keyPath
		self.callback = callback
		self.object = object
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		callback(change)
	}
	
	weak var object: NSObject?
	
	deinit {
		object?.removeObserver(self, forKeyPath: keyPath)
	}
}



extension NSObject {
	func observe(_ keyPath: String, options: NSKeyValueObservingOptions = [], callback: @escaping KeyValueObserver.KVOCallback) -> KeyValueObserver {
		let observer = KeyValueObserver(keyPath, callback, self)
		self.addObserver(observer, forKeyPath: keyPath, options: options, context: nil)
		return observer
	}
}
