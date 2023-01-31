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

	@Published var isActive: Bool
	@Published var configOriginal: URL?
	var configLinked: URL?

	private let activeSettingName: String = "ACTIVE"
	private let configOriginalSettingName: String = "CONFIGORIGINAL"
	private let configLinkedSettingName: String = "CONFIGLINKED" // TODO: This shouldn't be a setting.

	private let filepathPlaceholder: String = "FILE"
	private let configPlaceholder: String = "CONFIG"

	private let keyActive: String
	private let keyConfigOriginal: String
	private let keyConfigLinked: String // TODO: Use this

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
		// Set key paths
		self.keyActive = "\(self.exec).\(activeSettingName)"
		self.keyConfigOriginal = "\(self.exec).\(configOriginalSettingName)"
		self.keyConfigLinked = "\(self.exec).\(configLinkedSettingName)"
		// Read or initialize data
		self.isActive = (settings.value(forKey: keyActive) as? Bool) ?? false
		self.configOriginal = settings.value(forKey: keyConfigOriginal) == nil
			? nil
			: URL(fileURLWithPath: settings.value(forKey: keyConfigOriginal) as! String)
		self.configLinked = settings.value(forKey: keyConfigLinked) == nil
			? nil
			: URL(fileURLWithPath: settings.value(forKey: keyConfigLinked) as! String)
		// Make sure either both or neither config settings are nil
		if configOriginal == nil || configLinked == nil {
			configOriginal = nil
			configLinked = nil
			settings.setValue(nil, forKey: keyConfigOriginal)
			settings.setValue(nil, forKey: keyConfigLinked)
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
		// Update variables
		configOriginal = panel.url!
		configLinked = URL(fileURLWithPath: linksDirectory.path)
			.appendingPathComponent(exec)
			.appendingPathExtension("txt")
		// Relink config
		if fm.fileExists(atPath: configLinked!.path) {
			try! fm.removeItem(at: configLinked!)
		}
		try! fm.linkItem(at: panel.url!, to: configLinked!)
		// Update settings
		settings.setValue(panel.url!.path, forKey: keyConfigOriginal)
		settings.setValue(configLinked!.path, forKey: keyConfigLinked)
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
		// Open temporary file and copy in configuration
		// TODO: Do we need to copy the file? If we can figure out the files thing, maybe that'll be that.
		let configOriginal: URL = URL(fileURLWithPath: configOriginal!.path)
		let configTemp: URL = fm
			.temporaryDirectory
			.appendingPathComponent(UUID().uuidString)
			.appendingPathExtension("txt")
		do {
			try fm.copyItem(at: configOriginal, to: configTemp)
		} catch {
			return (false, 1, "Could not access \(configOriginal.path)")
		}
		// Parse and set arguments
		task.arguments = args.map {
			switch $0 {
				case filepathPlaceholder:
					return file.path
				case configPlaceholder:
					return configTemp.path
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
