//
//  DataSource.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/26/23.
//

import Foundation
import AppKit

class DataSource {

	enum ValidationError: Error {
		case InvalidInput
	}

	var contents: [ExecutableStep]

	init() {
		// Parse commands
		let dataCommands = NSDataAsset(name: "Commands")!.data
		// Parse versions
		let dataVersions = NSDataAsset(name: "Versions")!.data
		// Assemble contents
		self.contents = try! JSONDecoder().decode([ExecutableStep].self, from: dataCommands)
		// Decorrupt or initialize order data if needed
		if Array(Set(contents.map { $0.order })).count != contents.count
			|| contents.map({ $0.order }).contains(nil) {
			for i in 0..<contents.count {
				contents[i].setOrder(i)
			}
		}
		// Order steps
		contents = contents.sorted { $0.order! < $1.order! }
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
		for i in 1..<contents.count {
			contents[i].setOrder(i)
		}
	}

}
