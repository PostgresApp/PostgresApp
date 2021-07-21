//
//  SecondaryLabelColorTextField.swift
//  Postgres
//
//  Created by Jakob Egger on 21.07.21.
//  Copyright © 2021 postgresapp. All rights reserved.
//

import Cocoa

class SecondaryLabelColorTextField: NSTextField {
	override func awakeFromNib() {
		super.awakeFromNib()
		
		if #available(macOS 10.14, *) {
			// nothing to do
		} else {
			// secondary label color does not work properly in selected table cells on macOS 10.13 and earlier
			// we use control color instead
			self.textColor = .controlTextColor
		}
	}
}
