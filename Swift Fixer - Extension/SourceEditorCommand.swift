//
//  SourceEditorCommand.swift
//  swift-format-xcode-extension
//
//  Created by Jonathan Dayley on 1/20/23.
//

import Foundation
import System
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {

	func perform(
		with invocation: XCSourceEditorCommandInvocation,
		completionHandler: @escaping (Error?) -> Void
	) {

		// Make sure buffer is type Swift
		let uti: String = invocation.buffer.contentUTI
		let utiSwift: String = "public.swift-source"
		if uti != utiSwift {
			completionHandler(
				NSError(
					domain: "This is not Swift code.",
					code: 0
				)
			)
		}

		// Get current buffer lines and convert to text
		let bufferLines: NSMutableArray = invocation.buffer.lines

		// Get text version
		let txt: String = bufferLines.componentsJoined(by: "")

		// Get address of temporary file
		let fTemp: URL = FileManager
			.default
			.temporaryDirectory
			.appendingPathComponent(UUID().uuidString)
			.appendingPathExtension("swift")

		// Write to temporary file
		try? txt.write(to: fTemp, atomically: true, encoding: .utf8)

		// Run commands and catch errors
		var codeReturn: (status: Int, message: String)
		codeReturn = shell(
			command: "/usr/bin/env",
			args: [
				Bundle.main.url(
					forResource: "swift-format",
					withExtension: nil
				)!.path,
				"--configuration",
				Bundle.main.url(
					forResource: ".swift-format",
					withExtension: nil
				)!.path,
				"-i",
				fTemp.path,
			]
		)
		switch codeReturn.status { case 0: break default:
			completionHandler(
				NSError(
					domain: codeReturn.message.trimmingCharacters(
						in: .whitespacesAndNewlines
					),
					code: codeReturn.status
				)
			)
		}
		codeReturn = shell(
			command: "/usr/bin/env",
			args: [
				Bundle.main.url(
					forResource: "swiftlint",
					withExtension: nil
				)!.path,
				"--config",
				Bundle.main.url(
					forResource: ".swiftlint",
					withExtension: "yml"
				)!.path,
				"--fix",
				fTemp.path,
			]
		)
		switch codeReturn.status {
			case 0:
				break
			case 4:
				break
			default:
				completionHandler(
					NSError(
						domain: codeReturn.message.trimmingCharacters(
							in: .whitespacesAndNewlines
						),
						code: codeReturn.status
					)
				)
		}

		// Read in file
		let linesReadIn = try? String(contentsOfFile: fTemp.path)
			.components(separatedBy: "")

		// Replace buffer text
		bufferLines.removeAllObjects()
		bufferLines.addObjects(from: linesReadIn!)

		// Return
		completionHandler(nil)
	}

}
