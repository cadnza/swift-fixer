//
//  ConfigRow.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/25/23.
//

import SwiftUI

struct ConfigRow: View {

	private let exec: String
	private let ds: DataSource

	@State private var currentData: ExecutableStep

	init(exec: String, ds: DataSource){
		self.exec = exec
		self.ds = ds
		_currentData = State(
			initialValue: ds.contents.first(
				where: {x in
					return x.exec == exec
				}
			)!
		)
	}

	var body: some View {
		let bndIsActive = Binding {
			currentData.isActive
		}
		set: {x in
			currentData.setActive(value: x)
		}
		HStack {
			Text(verbatim: currentData.title)
				.fontWeight(.bold)
				.frame(width: 82.0)
			Toggle(isOn: bndIsActive) {
				Text(verbatim: "Enable")
			}
			TextField(
				"",
				text: Binding(
					get:{
						currentData.config?.path ?? ""
					}
				){_,_ in}
			)
			.disabled(true)
			Button(
				action: {
					currentData.setConfig()
				}, label: {
					Text(verbatim: "Config...")
				}
			)
			.disabled(!currentData.isActive)
			Button(
				action: {
					currentData.openWebsite()
				}, label: {
					Text(verbatim: "?")
				}
			)
		}
	}
}

struct ConfigRow_Previews: PreviewProvider {
	static var previews: some View {
		ContentView() //TEMP
					  //		ConfigRow(exec: "swift-format", ds: DataSource())
	}
}
