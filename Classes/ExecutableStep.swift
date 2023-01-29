//
//  File.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/25/23.
//

import AppKit
import Foundation

class ExecutableStep: Decodable, ObservableObject {

	private enum Keys: CodingKey {
		case title
		case website
		case description
		case exec
		case args
		case okayCodes
	}

	let title: String
	let website: String
	let description: String
	let exec: String
	let args: [String]
	let okayCodes: [Int]

	@Published var config: URL?
	@Published var isActive: Bool

	private let activeSettingName: String = "ACTIVE"
	private let configSettingName: String = "CONFIG"

	private let filepathPlaceholder: String = "FILE"
	private let configPlaceholder: String = "CONFIG"

	private let activeKeyPath: String
	private let configKeyPath: String

	private var settings: UserDefaults = UserDefaults()

	required init(from decoder: Decoder) {

		let container = try! decoder.container(keyedBy: Keys.self)

		self.title = try! container.decode(String.self, forKey: .title)
		self.website = try! container.decode(String.self, forKey: .website)
		self.description = try! container.decode(String.self, forKey: .description)
		self.exec = try! container.decode(String.self, forKey: .exec)
		self.args = try! container.decode([String].self, forKey: .args)
		self.okayCodes = try! container.decode([Int].self, forKey: .okayCodes)

		self.activeKeyPath = "\(self.exec).\(activeSettingName)"
		self.configKeyPath = "\(self.exec).\(configSettingName)"
		self.isActive = (settings.value(forKeyPath: activeKeyPath) as? Bool) ?? false
		self.config = settings.value(forKeyPath: configKeyPath) as? URL
	}

	func setActive(value: Bool) {
		if value && config == nil {
			setConfig()
			if config == nil {
				return
			}
		}
		settings.setValue(value, forKeyPath: activeKeyPath)
		isActive = value
	}

	func setConfig() {
		let panel = NSOpenPanel()
		panel.prompt = "Select"
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.canChooseFiles = true
		panel.canCreateDirectories = false
		panel.resolvesAliases = true
		panel.message = "Please select a config file for \(title)."
		panel.runModal()
		if panel.url != nil {
			settings.setValue(panel.url!.path, forKeyPath: configKeyPath)
			config = panel.url!
		}
	}

	func openWebsite() {
		NSWorkspace.shared.open(URL(string: website)!)
	}

	func execute(on file: URL) -> (
		success: Bool,
		status: Int,
		message: String
	) {
		// Open process and pipe
		let task = Process()
		let pipe = Pipe()
		// Set stdin and stderr
		task.standardOutput = pipe
		task.standardError = pipe
		// Parse and set arguments
		task.arguments = args.map {
			switch $0 {
				case filepathPlaceholder:
					return file.path
				case configPlaceholder:
					return config!.path
				default:
					return $0
			}
		}
		// Set launch path
		task.launchPath = Bundle.main.url(
			forResource: exec,
			withExtension: nil
		)!
			.path
		// Initialize stdin
		task.standardInput = nil
		// Run task
		do { try task.run() } catch { return (false, 1, "Could not run") }
		task.waitUntilExit()
		// Get exit code
		let code: Int = Int(task.terminationStatus)
		// Decide whether execution was successful
		let success: Bool = okayCodes.contains(code)
		// Capture output
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let output = String(data: data, encoding: .utf8)!.trimmingCharacters(
			in: .whitespacesAndNewlines
		)
		// Return
		return (success, code, output)
	}

}
