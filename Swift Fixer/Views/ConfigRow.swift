//
//  ConfigRow.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/25/23.
//

import SwiftUI

struct ConfigRow: View {

	@State var item: ExecutableStep

	var body: some View {
		HStack {
			Toggle(isOn: $item.isActive) {
				Text(verbatim: "Enable")
			}
			TextField("", text: $item.configFile)
				.scaledToFill()
				.disabled(true)
			Button(action: {() in
				item.configFile = "HERE" //TEMP
			}, label: {() in
				Text(verbatim: "Choose...")
			}
			)
			.disabled(!item.isActive)


		}
    }
}

struct ConfigRow_Previews: PreviewProvider {
    static var previews: some View {
		ConfigRow(item: ExecutableStep(name: "swift-format"))
    }
}
