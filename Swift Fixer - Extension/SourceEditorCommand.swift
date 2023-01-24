//
//  SourceEditorCommand.swift
//  swift-format-xcode-extension
//
//  Created by Jonathan Dayley on 1/20/23.
//

import Foundation
import XcodeKit
import System

class SourceEditorCommand: NSObject, XCSourceEditorCommand {

	func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {

		// Get current buffer lines and convert to text
		let bufferLines: NSMutableArray = invocation.buffer.lines
		let txt: String = bufferLines.componentsJoined(by: "") // Maybe make this not a \n //TEMP

		// Get address of temporary file
		let fTemp: URL = FileManager
			.default
			.temporaryDirectory
			.appendingPathComponent(UUID().uuidString)
			.appendingPathExtension("txt")
		//		let fTemp: URL = URL(fileURLWithPath: ".")
		//			.appendingPathComponent(".swift-fixer")

		// Write to temporary file
		try? txt.write(to: fTemp, atomically: true, encoding: .utf8)

		// Run command and catch error
		let codeReturn = shell(
			command:"/usr/bin/env",
			args:[
				"swift-format",
				"-i",
				fTemp.path
			]
		)
		switch(codeReturn.status){
			case 0:
				break
			default:
				completionHandler(
					NSError(
						domain: codeReturn.message.trimmingCharacters(in: .whitespacesAndNewlines),
						code: codeReturn.status
					)
				)
		}

		// Read in file
		let linesReadIn = try? String.init(contentsOfFile: fTemp.path).components(separatedBy: "")

		// Replace buffer text
		bufferLines.removeAllObjects()
		bufferLines.addObjects(from:linesReadIn!)

		// Return
		completionHandler(nil)
	}

}
