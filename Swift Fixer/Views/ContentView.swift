//
//  ContentView.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/23/23.
//

import Foundation
import SwiftUI

struct ContentView: View {

	private let dataSource = DataSource()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
			ConfigRow(exec: "swift-format", ds: dataSource)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
