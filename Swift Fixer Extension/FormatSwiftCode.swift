import Foundation
import System
import XcodeKit

class FormatSwiftCode: NSObject, XCSourceEditorCommand {

	func perform(
		with invocation: XCSourceEditorCommandInvocation,
		completionHandler: @escaping (Error?) -> Void
	) {

		// Get current buffer
		let bfr = invocation.buffer

		// Make sure buffer is type Swift
		let uti: String = bfr.contentUTI
		let utiSwift: String = "public.swift-source"
		guard uti == utiSwift else {
			completionHandler(
				NSError(
					domain: "This is not Swift code.",
					code: 0
				)
			)
			return
		}

		// Get current selection
		let currentSelFirst: XCSourceTextRange =
		(bfr.selections[0] as! XCSourceTextRange).copy()
		as! XCSourceTextRange

		// Open data source
		let ds = DataSource()

		// Get address of temporary file
		let fTemp: URL = FileManager
			.default
			.temporaryDirectory
			.appendingPathComponent(UUID().uuidString)
			.appendingPathExtension("swift")

		// Define file removal function
		func removeTempFile() {
			try? FileManager.default.removeItem(at: fTemp)
		}

		// Define erroring function
		func completeErr(
			domain: String,
			code: Int,
			removeFile: Bool = true
		) {
			if removeFile {
				removeTempFile()
			}
			completionHandler(NSError(domain: domain, code: code))
		}

		// Write to temporary file
		try? bfr.completeBuffer.write(
			to: fTemp,
			atomically: true,
			encoding: .utf8
		)

		// Open banner for non-blocking issue (holds only one)
		struct nonBlockingIssue {
			let code: Int
			let message: String
		}
		var nbiCurrent: nonBlockingIssue?

		// Run commands and catch errors and non-blocking issues
		let cmds = ds.contents.filter { $0.isActive }
		guard !cmds.isEmpty else {
			completeErr(
				domain: "No commands active.",
				code: 0
			)
			return
		}
		for cmd in cmds {
			let codeReturn = cmd.execute(on: fTemp)
			let otherAcceptableCodesAndMessages = [
				5: "\(cmd.title) was skipped due to a sandbox issue."
			]
			let triggeredOther = otherAcceptableCodesAndMessages
				.keys
				.contains(codeReturn.status)
			guard codeReturn.success || triggeredOther else {
				completeErr(
					domain: cmd.title,
					code: codeReturn.status
				)
				return
			}
			if triggeredOther && nbiCurrent == nil {
				nbiCurrent = nonBlockingIssue.init(
					code: codeReturn.status,
					message: otherAcceptableCodesAndMessages[codeReturn.status]!
				)
			}
		}

		// Read in file
		let linesReadIn = try? String(contentsOfFile: fTemp.path)
			.components(separatedBy: "")

		// Replace buffer text
		bfr.lines.removeAllObjects()
		bfr.lines.addObjects(from: linesReadIn!)

		// Restore selection
		bfr.selections[0] = currentSelFirst

		// Delete temp file
		removeTempFile()

		// Return
		if let nbiCurrentU = nbiCurrent {
			// FIXME: This is where we use the data contained in nbiCurrentU to let the user know that one of the steps was skipped and why. We need to find a way to do that.
		}
		completionHandler(nil)
	}

}
