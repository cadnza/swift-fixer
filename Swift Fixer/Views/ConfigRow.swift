//
//  ConfigRow.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/25/23.
//

import SwiftUI

struct ConfigRow: View {

	@State var fPath: String
	@State var isChecked: Bool

	var body: some View {
		HStack {
			Toggle(isOn: $isChecked) {
				Text(verbatim: "Enable")
			}
			TextField("Time", text: $fPath)
				.scaledToFill()
				.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
			Button(action: {() in
				fPath = "Here" //TEMP
			}, label: {() in
				Text(verbatim: "Choose")
			}
			)
			.disabled(!isChecked)


		}
    }
}

struct ConfigRow_Previews: PreviewProvider {
    static var previews: some View {
		ConfigRow(fPath: "/usr/local/bin/swift-format", isChecked: true)
    }
}
