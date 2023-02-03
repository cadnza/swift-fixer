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
		// Decorrupt order data if needed
		if Array(Set(contents.map { $0.order })).count != contents.count {
			for i in 0..<contents.count {
				contents[i].setOrder(i)
			}
		}
		// Order steps
		orderSteps()
		// Add versions
		let versions = try! JSONDecoder().decode([Version].self, from: dataVersions)
		self.contents.forEach { e in
			e.version = versions.first { v in
				v.exec == e.exec
			}?.version
		}
	}

	func moveStep(from old: Int, to new: Int) {
		if new == old {
			return
		}
		let stepToMove = contents.first { $0.order == old }!
		if new < old {
			contents.filter {
				$0.order >= new && $0.order < old
			}
			.forEach {
				$0.setOrder($0.order + 1)
			}
		}
		if new > old {
			contents.filter {
				$0.order > old && $0.order <= new
			}
			.forEach {
				$0.setOrder($0.order - 1)
			}
		}
		stepToMove.setOrder(new)
		orderSteps()
	}

	func orderSteps() {
		contents = contents.sorted { $0.order < $1.order }
		for i in 1..<contents.count {
			contents[i].setOrder(i)
		}
	}

}
