import Foundation
import SwiftUI

struct ContentView: View {

	@StateObject private var ds = DataSource()

	let width: CGFloat = 400
	let height: CGFloat = 600

	let appName = "Swift Fixer"
	let authorName = "cadnza"
	let authorSite = URL(string: "https://github.com/cadnza")!

	var body: some View {
		ZStack {
			Color("BackgroundColor").ignoresSafeArea()
			VStack {
				HStack {
					Image("Logo")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(height: 50.0)
					Spacer()
					VStack(alignment: .trailing) {
						Text(appName)
							.font(.title)
							.fontWeight(.black)
						Link(authorName, destination: authorSite)
							.font(.title2)
							.foregroundColor(.accentColor)
					}
				}
				.padding(.horizontal, 17.0)
				List {
					ForEach(ds.contents) {
						ConfigRow(id: $0.id, ds: ds)
					}
					.onMove(perform: ds.move)
				}
				.animation(.default, value: ds.contents)
				Link(
					"Help",
					destination: URL(string: "https://github.com/cadnza/swift-fixer")! // FIXME: Point this to README file
				)
				.foregroundColor(Color.accentColor)
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
