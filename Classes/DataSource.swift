//
//  DataSource.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/26/23.
//

import Foundation
import AppKit

struct DataSource {

	enum ValidationError: Error {
		case InvalidInput
	}

	let contents: [ExecutableStep]

	init() {
		// Parse commands
		let dataCommands = NSDataAsset(name: "Commands")!.data
		// Parse versions
		let dataVersions = NSDataAsset(name: "Versions")!.data
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

	func moveStep(from old: Int, to new: Int) throws {
		if new == old {
			throw ValidationError.InvalidInput
		}
		if new < old {
			contents.filter {
				$0.order >= new && $0.order < old
			}.forEach {
				$0.order += 1
			}
		}
		if new > old {
			contents.filter {
				$0.order > old && $0.order <= new
			}.forEach {
				$0.order -= 1
			}
		}
	}

}
