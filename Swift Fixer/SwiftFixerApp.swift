import SwiftUI

@main
struct SwiftFixerApp: App {

	let width: CGFloat = 400
	let height: CGFloat = 600

    var body: some Scene {
        WindowGroup {
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
