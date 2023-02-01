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

	var version: String?

	private let args: [String]
	private let okayCodes: [Int]

	@Published var isActive: Bool
	@Published var configOriginal: URL?

	let configLinked: URL

	private let activeSettingName: String = "ACTIVE"
	private let configSettingName: String = "CONFIG"

	private let filepathPlaceholder: String = "FILE"
	private let configPlaceholder: String = "CONFIG"

	private let keyActive: String
	private let keyConfig: String

	private let appGroupId: String = "9TVGLBSJNB.swift-fixer"

	private var settings: UserDefaults

	private var linksDirectory: URL

	private var fm: FileManager

	required init(from decoder: Decoder) {
		let container = try! decoder.container(keyedBy: Keys.self)
		// Initialize settings
		self.settings = UserDefaults(suiteName: appGroupId)!
		// Initilize file manager
		self.fm = FileManager.default
		// Create links directory
		self.linksDirectory = fm
			.containerURL(forSecurityApplicationGroupIdentifier: appGroupId)!
			.appendingPathComponent("Links")
		if !fm.fileExists(atPath: linksDirectory.path) {
			try! fm.createDirectory(at: linksDirectory, withIntermediateDirectories: true)
		}
		// Read properties
		self.title = try! container.decode(String.self, forKey: .title)
		self.website = try! container.decode(String.self, forKey: .website)
		self.description = try! container.decode(String.self, forKey: .description)
		self.exec = try! container.decode(String.self, forKey: .exec)
		self.args = try! container.decode([String].self, forKey: .args)
		self.okayCodes = try! container.decode([Int].self, forKey: .okayCodes)
		// Assign linked config path
		self.configLinked = linksDirectory
			.appendingPathComponent(exec)
		// Set key paths
		self.keyActive = "\(self.exec).\(activeSettingName)"
		self.keyConfig = "\(self.exec).\(configSettingName)"
		// Read or initialize data
		self.isActive = (settings.value(forKey: keyActive) as? Bool) ?? false
		self.configOriginal = settings.value(forKey: keyConfig) == nil
			? nil
			: URL(fileURLWithPath: settings.value(forKey: keyConfig) as! String)
		// Make sure either both or neither config settings are nil
		if !fm.fileExists(atPath: configLinked.path) {
			configOriginal = nil
			settings.setValue(configOriginal, forKey: keyConfig)
			isActive = false
			settings.setValue(isActive, forKey: keyActive)
		}
	}

	func setActive(value: Bool) {
		if value && configOriginal == nil {
			setConfig()
			if configOriginal == nil {
				return
			}
		}
		settings.setValue(value, forKey: keyActive)
		isActive = value
	}

	func setConfig() {
		// Get user input from panel
		let panel = NSOpenPanel()
		panel.prompt = "Select"
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.canChooseFiles = true
		panel.canCreateDirectories = false
		panel.resolvesAliases = true
		panel.message = "Please select a config file for \(title)."
		panel.runModal()
		// Return on no input
		if panel.url == nil {
			return
		}
		// Update variable
		configOriginal = panel.url!
		// Relink config
		if fm.fileExists(atPath: configLinked.path) {
			try! fm.removeItem(at: configLinked)
		}
		try! fm.linkItem(at: panel.url!, to: configLinked)
		// Update settings
		settings.setValue(panel.url!.path, forKey: keyConfig)
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
		// Make sure config file still exists
		if !fm.fileExists(atPath: configOriginal!.path) {
			return (false, 1, "Could not find \(configOriginal!.path)")
		}
		// Parse and set arguments
		task.arguments = args.map {
			switch $0 {
				case filepathPlaceholder:
					return file.path
				case configPlaceholder:
					return configLinked.path
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
