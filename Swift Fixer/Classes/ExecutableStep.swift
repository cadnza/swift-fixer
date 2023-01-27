//
//  File.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/25/23.
//

import AppKit
import Foundation

struct ExecutableStep: Decodable {

	private enum Keys : String, CodingKey { case
		title,
		website,
		description,
		exec,
		args
	}

	let title: String
	let website: String
	let description: String
	let exec: String
	let args: [String]

	var config: String?
	var isActive: Bool

	private let activeSettingName: String = "ACTIVE"
	private let configSettingName: String = "CONFIG"

	private let activeKeyPath: String
	private let configKeyPath: String

	private var settings = UserDefaults()

	init(from decoder: Decoder) {

		let container = try! decoder.container(keyedBy: Keys.self)
		
		self.title = try! container.decode(String.self, forKey: .title)
		self.website = try! container.decode(String.self, forKey: .website)
		self.description = try! container.decode(String.self, forKey: .description)
		self.exec = try! container.decode(String.self, forKey: .exec)
		self.args = try! container.decode([String].self, forKey: .args)

		self.activeKeyPath = "\(self.exec).\(activeSettingName)"
		self.configKeyPath = "\(self.exec).\(configSettingName)"
		self.isActive = (settings.value(forKeyPath: activeKeyPath) as? Bool) ?? false
		self.config = (settings.value(forKeyPath: configKeyPath) as? String)
	}

	mutating func setActive(value: Bool) {
		settings.setValue(value, forKeyPath: activeKeyPath)
		self.isActive = value
	}

	mutating func setConfig() {
		let panel = NSOpenPanel()
		panel.prompt = "Select"
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = false
		panel.canChooseFiles = true
		panel.canCreateDirectories = false
		panel.resolvesAliases = true
		panel.message = "Please select a config file for \(title)."
		panel.runModal()
		if(panel.url != nil){
			settings.setValue(panel.url!.path, forKeyPath: configKeyPath)
			self.config = panel.url!.path
		}
	}

	func openWebsite() {
		NSWorkspace.shared.open(URL(string: website)!)
	}

}
