//
//  DataSource.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/26/23.
//

import Foundation
import AppKit

class DataSource: ObservableObject {

	enum ValidationError: Error {
		case InvalidInput
	}

	@Published var contents: [ExecutableStep]

	private let settings = Settings()

	private let orderSettingName = "ORDER"

	init() {
		// Parse commands
		let dataCommands = NSDataAsset(name: "Commands")!.data
		// Parse versions
		let dataVersions = NSDataAsset(name: "Versions")!.data
		// Assemble contents
		self.contents = try! JSONDecoder().decode([ExecutableStep].self, from: dataCommands)
		// Order from settings if possible
		let setOrder = settings.value(forKey: orderSettingName) as? [String]
		if setOrder != nil {
			if setOrder!.count == contents.count && setOrder!.sorted() == contents.map({ $0.exec }).sorted() {
				contents = setOrder!.map { x in
					contents.first { $0.exec == x }!
				}
			} else {
				settings.removeObject(forKey: orderSettingName)
			}
		}
		// Add versions
		let versions = try! JSONDecoder().decode([Version].self, from: dataVersions)
		self.contents.forEach { e in
			e.version = versions.first { v in
				v.exec == e.exec
			}?.version
		}
	}

	func move(fromOffsets source: IndexSet, toOffset destination: Int) {
		contents.move(fromOffsets: source, toOffset: destination)
		settings.setValue(
			contents.map { $0.exec },
			forKey: orderSettingName
		)
	}

}
