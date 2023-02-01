//
//  DataSource.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/26/23.
//

import Foundation

struct DataSource {

	let contents: [ExecutableStep]

	init() {
		// Parse commands
		let jsonCommands = "commands"
		let urlCommands = Bundle.main.url(forResource: jsonCommands, withExtension: "json")
		let dataCommands = try! Data(contentsOf: urlCommands!)
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
