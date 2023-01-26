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
		self.currentData = ds.contents.first(
			where: {x in
				return x.exec == exec
			}
		)!
	}

	var body: some View {
		HStack {
			Text(verbatim: currentData.title)
				.fontWeight(.bold)
				.frame(width: 82.0)
			Toggle(isOn: $currentData.isActive) {
				Text(verbatim: "Enable")
			}
			TextField("", text: $currentData.config)
				.scaledToFill()
				.disabled(true)
			Button(action: {() in
				currentData.setConfig()
			}, label: {() in
				Text(verbatim: "Config...")
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
