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
		let colorChangesToDefault = currentData.isActive ? nil : Color("InactiveColor")

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
				.foregroundColor(colorChangesToAccent)
				if currentData.subcommand != nil {
					Text(verbatim: currentData.subcommand!)
						.font(.title3.monospaced())
						.foregroundColor(colorChangesToDefault)
				}
				Spacer()
				Text(verbatim: "v\(currentData.version!)")
					.foregroundColor(colorChangesToDefault)
			}
			HStack {
				Link(
					currentData.author, destination: URL(string: currentData.authorSite)!
				)
				.foregroundColor(colorChangesToAccent)
				Spacer()
			}
			HStack {
				Text(verbatim: currentData.configOriginal?.path ?? "Unset") // FIXME: Make this a link
					.foregroundColor(colorChangesToAccent)
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
	}
}

struct ConfigRow_Previews: PreviewProvider {
	static var previews: some View {
		ContentView() // TODO: Reset view
		//		ConfigRow(exec: "swiftlint", ds: DataSource())
	}
}
