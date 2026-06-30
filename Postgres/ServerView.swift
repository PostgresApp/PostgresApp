//
//  ServerView.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  This code is released under the terms of the PostgreSQL License.
//

import Cocoa

class ServerViewController: NSViewController, MainWindowModelConsumer {
	@objc dynamic var mainWindowModel: MainWindowModel!
	
	@IBOutlet weak var stopButton: NSButton!
	@IBOutlet weak var startButton: NSButton!
	
	override func viewWillAppear() {
		self.view.window?.addObserver(self, forKeyPath: "firstResponder", context: nil)
		super.viewWillAppear()
	}
	
	override func viewWillDisappear() {
		self.view.window?.removeObserver(self, forKeyPath: "firstResponder")
		super.viewWillDisappear()
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "firstResponder" {
			if self.view.window?.firstResponder is DatabaseCollectionView {
				self.startButton.keyEquivalent = ""
				self.stopButton.keyEquivalent = ""
			} else {
				self.startButton.keyEquivalent = "\r"
				self.stopButton.keyEquivalent = "\r"
			}
			return
		}
		super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
	}
	
	@IBAction func startServer(_ sender: AnyObject?) {
		guard let server = mainWindowModel.firstSelectedServer else { return }
		server.start { result in
			if case let .failure(error) = result {
				self.presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
			}
		}
	}
	
	
	@IBAction func stopServer(_ sender: AnyObject?) {
		guard let server = mainWindowModel.firstSelectedServer else { return }
		server.stop { result in
			if case let .failure(error) = result {
				self.presentError(error, modalFor: self.view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
			}
		}
	}
	
	
	@IBAction func openPsql(_ sender: AnyObject?) {
		guard let server = mainWindowModel.firstSelectedServer else { return }
		guard let database = server.firstSelectedDatabase else { return }
		
		if let clientApplicationPath = UserDefaults.standard.string(forKey: "PreferredClientApplicationPath") {
			Task {
				do {
					try await ClientLauncher.shared.launchClient(URL(fileURLWithPath: clientApplicationPath), server: server, databaseName: database.name)
				}
				catch let error {
					presentError(error, modalFor: view.window!, delegate: nil, didPresent: nil, contextInfo: nil)
				}
			}
		} else {
			performSegue(withIdentifier: "ConnectionDialogSegue", sender: sender)
		}
	}
	
	@IBAction func warningButtonClicked(_ sender: AnyObject?) {
		guard let server = mainWindowModel.firstSelectedServer else { return }
		server.showWarningDetails(modalFor: view.window!)
	}
	
	@IBAction func clientPermissionWarningButtonClicked(_ sender: AnyObject?) {
		NSWorkspace.shared.open(URL(string: "https://postgresapp.com/l/app-permissions/")!)
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if let target = segue.destinationController as? SettingsViewController {
			guard let server = mainWindowModel.firstSelectedServer else { return }
			target.server = server
		}
		if let connectionDialog = segue.destinationController as? ConnectionDialog {
			guard let server = mainWindowModel.firstSelectedServer else { return }
			connectionDialog.server = server
		}
	}
	
}



class ServerViewBackgroundView: NSView {
	override var isOpaque: Bool { return true }
	override var mouseDownCanMoveWindow: Bool { return true }
	
	override func draw(_ dirtyRect: NSRect) {
		NSColor.controlBackgroundColor.setFill()
		dirtyRect.fill()
		
		let imgSize = CGFloat(96)
		let x = CGFloat(self.bounds.maxX-imgSize-20), y = CGFloat(20)
		let imageRect = NSRect(x: x, y: self.bounds.maxY-y-imgSize, width: imgSize, height: imgSize)
		if imageRect.intersects(dirtyRect) {
			NSImage(named: "BlueElephant")?.draw(in: imageRect)
		}
	}
}



