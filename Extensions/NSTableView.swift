import Foundation
import SwiftUI

extension NSTableView {
	override open func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()

		backgroundColor = NSColor.clear
		enclosingScrollView!.drawsBackground = false
	}
}
