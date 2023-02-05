import SwiftUI

struct ConfigRow: View {

	private let exec: String
	private let ds: DataSource

	@ObservedObject private var currentData: ExecutableStep

	init(exec: String, ds: DataSource) {
		self.exec = exec
		self.ds = ds
		self.currentData = ds.contents.first { $0.exec == exec }!
	}

	var body: some View {

		let colorChangesToAccent = Color(currentData.isActive ? "AccentColor" : "AccentColorInactive")
		let colorChangesToDefault = currentData.isActive ? Color.primary : Color("InactiveColor")

		let bndIsActive: Binding<Bool> = Binding(
			get: {
				currentData.isActive
			},
			set: {
				currentData.setActive($0)
			}
		)

		VStack {
			HStack {
				Link(
					currentData.title, destination: URL(string: currentData.website)!
				)
				.font(.title.bold())
				.foregroundColor(Color.white)
				.colorMultiply(colorChangesToAccent)
				.animation(.default, value: currentData.isActive)
				if currentData.subcommand != nil {
					Text(verbatim: currentData.subcommand!)
						.font(.title3.monospaced())
						.foregroundColor(Color.white)
						.colorMultiply(colorChangesToDefault)
						.animation(.default, value: currentData.isActive)
				}
				Spacer()
				Text(verbatim: "v\(currentData.version!)")
					.foregroundColor(Color.white)
					.colorMultiply(colorChangesToDefault)
					.animation(.default, value: currentData.isActive)
			}
			HStack {
				Link(
					currentData.author, destination: URL(string: currentData.authorSite)!
				)
				.foregroundColor(Color.white)
				.colorMultiply(colorChangesToAccent)
				.animation(.default, value: currentData.isActive)
				Spacer()
			}
			HStack {
				if currentData.configOriginal == nil {
					Text(verbatim: "Config file not set")
						.foregroundColor(Color("InactiveColor"))
						.italic()
				} else {
					Text(verbatim: currentData.configOriginal!.path)
						.foregroundColor(Color.white)
						.colorMultiply(colorChangesToDefault)
						.animation(.default, value: currentData.isActive)
						.truncationMode(.middle)
				}
				Spacer()
			}
			HStack {
				Toggle(isOn: bndIsActive) {
					Text(verbatim: "Enable")
				}
				Spacer()
				Button(
					action: {
						currentData.setConfig()
					}, label: {
						Text(verbatim: "Config...")
					}
				)
				.disabled(!currentData.isActive)
				.animation(.default, value: currentData.isActive)
			}
		}
		.padding()
		.overlay(
			RoundedRectangle(cornerRadius: 5)
				.stroke(
					colorChangesToAccent,
					lineWidth: 1
				)
		)
		.animation(.default, value: currentData.isActive)
	}
}

struct ConfigRow_Previews: PreviewProvider {
	static var previews: some View {
		ContentView() // TODO: Reset view
		//		ConfigRow(exec: "swiftlint", ds: DataSource())
	}
}
