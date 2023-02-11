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
				VStack {
					Text(verbatim: "Setup").font(.title)
					VStack {
						HStack {
							Text(verbatim: "Open ") + Text(verbatim: "System Preferences").bold()
							Spacer()
						}
						HStack {
							Text(verbatim: "Navigate to ") + Text(verbatim: "Extensions").bold()
							Spacer()
						}
						HStack {
							Text(verbatim: "Open ") + Text(verbatim: "Xcode Source Editor").bold()
							Spacer()
						}
						HStack {
							Text(verbatim: "Enable ") + Text(verbatim: "Swift Fixer Extension").bold()
							Spacer()
						}
					}
					.padding()
					Text(verbatim: "Use")
						.font(.title)
					VStack {
						HStack {
							Text(verbatim: "Enable").bold()
							Spacer()
							Text(verbatim: "Enable a formatter")
						}
						HStack {
							Text(verbatim: "Config...").bold()
							Spacer()
							Text(verbatim: "Link a configuration file")
						}
						HStack {
							Text(verbatim: "Drag / Drop").bold()
							Spacer()
							Text(verbatim: "Assign execution order in Xcode")
						}
					}
					.padding()
					HStack {
						Text(verbatim: "XCode → Editor → Swift Fixer → Format Swift Code")
					}
					.padding()
				}
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
