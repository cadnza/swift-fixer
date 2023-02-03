//
//  ContentView.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/23/23.
//

import Foundation
import SwiftUI

struct ContentView: View {

	private let ds = DataSource()

	var body: some View {
		ZStack {
			Color("BackgroundColor").ignoresSafeArea()
			VStack {
				Image("Logo")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(height: 45.0)
				Text("Hello, world!")
				List {
					ForEach(ds.contents, id: \.exec) {
						ConfigRow(exec: $0.exec, ds: ds)
					}.onMove { indeces, new in
						let old: Int = Array(indeces)[0]
						ds.moveStep(from: old, to: new)
					}
				}
			}
			.padding()
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
