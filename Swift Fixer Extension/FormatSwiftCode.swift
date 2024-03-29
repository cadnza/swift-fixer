import Foundation
import System
import UserNotifications
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

		// Open list of non-blocking issues (holds only one)
		struct nonBlockingIssue {
			let code: Int
			let messageMain: String
			let messageElaboration: String
		}
		var NBIs: [nonBlockingIssue] = []

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
			if triggeredOther {
				NBIs.append(
					nonBlockingIssue.init(
						code: codeReturn.status,
						messageMain: otherAcceptableCodesAndMessages[
							codeReturn.status
						]!,
						messageElaboration: "Skipped \(cmd.title)"
					)
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

		// Notify if something didn't work
		NBIs.forEach { nbiCurrent in
			let nCenter = UNUserNotificationCenter.current()
			nCenter.requestAuthorization(options: [.alert, .sound]) {
				granted,
				error in
			}
			nCenter.getNotificationSettings { settings in
				guard settings.authorizationStatus == .authorized else {
					return
				}
				let nContent = UNMutableNotificationContent()
				if settings.alertSetting == .enabled {
					nContent.title = nbiCurrent.messageElaboration
					nContent.body = nbiCurrent.messageMain
				}
				if settings.soundSetting == .enabled {
					nContent.sound = .default
				}
				let nRequest = UNNotificationRequest(
					identifier: UUID().uuidString,
					content: nContent,
					trigger: nil
				)
				nCenter.add(nRequest)
			}
		}

		// Return
		completionHandler(nil)
	}

}
