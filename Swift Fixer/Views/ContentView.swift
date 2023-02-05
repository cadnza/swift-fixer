import Foundation
import SwiftUI

struct ContentView: View {

	@StateObject private var ds = DataSource()

	let width: CGFloat = 400
	let height: CGFloat = 600

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
					ForEach(ds.contents) {
						ConfigRow(exec: $0.exec, ds: ds)
					}
					.onMove(perform: ds.move)
				}
				.animation(.default, value: ds.contents)
			}
			.padding()
		}
		.frame(
			minWidth: width,
			maxWidth: width,
			minHeight: height,
			maxHeight: height
		)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
