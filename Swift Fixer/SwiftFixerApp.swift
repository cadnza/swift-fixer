//
//  SwiftFixerApp.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/23/23.
//

import SwiftUI

@main
struct SwiftFixerApp: App {

	let width: CGFloat = 600
	let height: CGFloat = 300

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
