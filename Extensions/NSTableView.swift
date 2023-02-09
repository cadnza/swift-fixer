import Foundation
import SwiftUI

extension NSTableView {
	// swiftlint:disable:next override_in_extension
	override open func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()

		backgroundColor = NSColor.clear
		enclosingScrollView?.drawsBackground = false
	}
}
