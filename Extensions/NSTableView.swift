//
//  NSTableView.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 2/1/23.
//

import Foundation
import SwiftUI

extension NSTableView {
	open override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()

		backgroundColor = NSColor.clear
		enclosingScrollView!.drawsBackground = false
	}
}
