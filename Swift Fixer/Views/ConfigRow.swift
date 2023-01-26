//
//  ConfigRow.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/25/23.
//

import SwiftUI

struct ConfigRow: View {

	let exec: String
	let ds: DataSource

	@State private var currentData: ExecutableStep

	init(exec: String, ds: DataSource){
		self.exec = exec
		self.ds = ds
		self.currentData = ds.contents.first(
			where: {x in
				return x.exec == exec
			}
		)!
	}

	var body: some View {
		HStack {
			Toggle(isOn: $currentData.isActive) {
				Text(verbatim: "Enable")
			}
			TextField("", text: $currentData.config)
				.scaledToFill()
				.disabled(true)
			Button(action: {() in
				currentData.setConfig()
			}, label: {() in
				Text(verbatim: "Choose...")
			}
			)
			.disabled(!currentData.isActive)


		}
	}
}

struct ConfigRow_Previews: PreviewProvider {
	static var previews: some View {
		ConfigRow(exec: "swift-format", ds: DataSource())
	}
}
