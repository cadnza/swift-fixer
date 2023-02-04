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
		let bndIsActive: Binding<Bool> = Binding(
			get: {
				currentData.isActive
			},
			set: {
				currentData.setActive($0)
			}
		)
		HStack {
			Link(
				currentData.title, destination: URL(string: currentData.website)!
			)
			.font(.title)
			.foregroundColor(Color("AccentColor"))
			if currentData.subcommand != nil {
				Text(verbatim: currentData.subcommand!)
					.font(.title)
			}
			Spacer()
		}
		HStack {
			Link(
				currentData.author, destination: URL(string: currentData.authorSite)!
			)
			.foregroundColor(Color("AccentColor"))
			Spacer()
		}
		TextField(
			"",
			text: Binding(
				get: {
					currentData.configOriginal?.path ?? ""
				},
				set: {_, _ in
				}
			)
		)
		.textFieldStyle(.plain)
		.disabled(true)
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
		}
		.disabled(!currentData.isActive)
	}
}

struct ConfigRow_Previews: PreviewProvider {
	static var previews: some View {
		ContentView() // TODO: Reset view
		//		ConfigRow(exec: "swiftlint", ds: DataSource())
	}
}
