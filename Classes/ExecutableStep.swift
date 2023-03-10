import AppKit
import Foundation

class ExecutableStep: Decodable, ObservableObject, Identifiable, Equatable {

	let id = UUID()

	private enum Keys: CodingKey {
		case title
		case subcommand
		case website
		case description
		case exec
		case args
		case okayCodes
		case author
		case authorSite
	}

	let title: String
	let subcommand: String?
	let website: String
	let description: String
	let exec: String

	let author: String
	let authorSite: String

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

	private let settings = Settings()

	private var linksDirectory: URL

	private let fm = FileManager.default

	static func == (lhs: ExecutableStep, rhs: ExecutableStep) -> Bool {
		lhs.id == rhs.id
	}

	required init(from decoder: Decoder) {
		let container = try! decoder.container(keyedBy: Keys.self)
		// Create links directory
		self.linksDirectory = fm
			.containerURL(forSecurityApplicationGroupIdentifier: settings.appGroupId)!
			.appendingPathComponent("Library")
			.appendingPathComponent("Application Support")
			.appendingPathComponent("Links")
		if !fm.fileExists(atPath: linksDirectory.path) {
			try! fm.createDirectory(at: linksDirectory, withIntermediateDirectories: true)
		}
		// Read properties
		self.title = try! container.decode(String.self, forKey: .title)
		self.subcommand = try? container.decode(String.self, forKey: .subcommand)
		self.website = try! container.decode(String.self, forKey: .website)
		self.description = try! container.decode(String.self, forKey: .description)
		self.exec = try! container.decode(String.self, forKey: .exec)
		self.args = try! container.decode([String].self, forKey: .args)
		self.okayCodes = try! container.decode([Int].self, forKey: .okayCodes)
		self.author = try! container.decode(String.self, forKey: .author)
		self.authorSite = try! container.decode(String.self, forKey: .authorSite)
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
		// Validate hard link to config
		if !fm.fileExists(atPath: configLinked.path) {
			configOriginal = nil
			settings.setValue(configOriginal, forKey: keyConfig)
			isActive = false
			settings.setValue(isActive, forKey: keyActive)
		}
	}

	func setActive(_ value: Bool) {
		if value && configOriginal == nil {
			setConfig()
			guard configOriginal != nil else {
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
		guard panel.url != nil else {
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
		guard fm.fileExists(atPath: configOriginal!.path) else {
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
