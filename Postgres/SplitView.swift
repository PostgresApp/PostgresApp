//
//  SplitView.swift
//  Postgres
//
//  Created by Chris on 24/06/16.
//  This code is released under the terms of the PostgreSQL License.
//

import Cocoa

// I've tried to configure the split view in a manner that the sidebar should never be collapsed
// However, when restoring state from a previous version of Postgres.app, it is possible that
// the subview is restored in a collapsed state. For this reason, we make sure that all
// subviews of the splitview are unhidden after restoring state
//
// A side effect of this workaround is that if a subview is ever collapsed due to a bug in macOS,
// then restarting the app should fix the problem.
class UncollapsibleSplitView: NSSplitView {
	override func restoreState(with coder: NSCoder) {
		super.restoreState(with: coder)
		for subview in self.arrangedSubviews {
			subview.isHidden = false
		}
	}
	
	override func awakeFromNib() {
		for subview in self.arrangedSubviews {
			subview.isHidden = false
		}
		super.awakeFromNib()
	}
}


class MainSplitViewController: NSSplitViewController {
	override func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
		return false
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		for item in splitViewItems {
			item.canCollapse = false
		}
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		if let toolbar = view.window?.toolbar {
			if !toolbar.items.contains(where: {$0.itemIdentifier == .sidebarTrackingSeparator}) {
				toolbar.insertItem(withItemIdentifier: .sidebarTrackingSeparator, at: toolbar.items.count)
			}
		}
	}
}
