import SwiftUI

@main
struct SwiftFixerApp: App {

	let width: CGFloat = 400
	let height: CGFloat = 600

    var body: some Scene {
        WindowGroup { // FIXME: Make this into a Window instead (requires macOS 13+)
            ContentView()
				.frame(
					minWidth: width,
					maxWidth: width,
					minHeight: height,
					maxHeight: height
				)
        }
		.windowStyle(HiddenTitleBarWindowStyle())
    }
}
