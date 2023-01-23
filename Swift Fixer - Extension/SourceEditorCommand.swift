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
		let txt: String = bufferLines.componentsJoined(by: "\n")

		// Get address of temporary file
		let fTemp: URL = FileManager
			.default
			.temporaryDirectory
			.appendingPathComponent(UUID().uuidString)
			.appendingPathExtension("txt")

		// Write to temporary file
		try? txt.write(to: fTemp, atomically: true, encoding: .utf8)

		// Run command
//		let urlSwiftFormat: URL = URL(string: "/usr/bin/env")!
//		do {
//			let task = try NSUserUnixTask(url: urlSwiftFormat)
//			task.execute(
//				withArguments: [
//					"swift-format",
//					"-i",
//					urlSwiftFormat.path
//				]
//			)
//		} catch {
//			print("HERE") //TEMP
//		}

		// Read in file
//		let linesReadIn = try? String.init(contentsOfFile: fTemp.path).components(separatedBy: "\n")

		// Replace buffer text
//		bufferLines.removeAllObjects()
//		bufferLines.addObjects(from:linesReadIn!)

		// Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.

		// Return
		completionHandler(nil)
	}

}
