import SwiftUI

@main
struct SwiftFixerApp: App {
    var body: some Scene {
        WindowGroup { // FIXME: Make this into a Window instead (requires macOS 13+)
            ContentView()
        }
		.windowStyle(HiddenTitleBarWindowStyle())
    }
}
