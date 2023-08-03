import SwiftUI

@main
struct SwiftFixerApp: App {
    var body: some Scene {
		Window("main", id: "main") {
			ContentView()
        }
		.windowStyle(HiddenTitleBarWindowStyle())
		.windowResizability(.contentSize)
    }
}
