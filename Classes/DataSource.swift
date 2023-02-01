//
//  DataSource.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/26/23.
//

import Foundation
import AppKit

struct DataSource {

	let contents: [ExecutableStep]

	init() {
		// Parse commands
		let dataCommands = NSDataAsset(name: "Commands")!.data
		// Parse versions
		let jsonVersions = "versions"
		let urlVersions = Bundle.main.url(forResource: jsonVersions, withExtension: "json")
		let dataVersions = try! Data(contentsOf: urlVersions!)
		// Assemble contents
		self.contents = try! JSONDecoder().decode([ExecutableStep].self, from: dataCommands)
		// Add versions
		let versions = try! JSONDecoder().decode([Version].self, from: dataVersions)
		self.contents.forEach { e in
			e.version = versions.first { v in
				v.exec == e.exec
			}?.version
		}
	}

}
