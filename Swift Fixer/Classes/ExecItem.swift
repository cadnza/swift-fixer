//
//  File.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/25/23.
//

import Foundation

struct ExecutableStep {

	let name: String

	var configFile: String?
	var isActive: Bool

	let activeSettingName: String = "ACTIVE"
	let configSettingName: String = "CONFIG"

	let activeKeyPath: String
	let configKeyPath: String

	var settings = UserDefaults()

	init(name: String) {
		self.name = name
		self.activeKeyPath = "\(name).\(activeSettingName)"
		self.configKeyPath = "\(name).\(configSettingName)"
		self.isActive = (settings.value(forKeyPath: activeKeyPath) as? Bool) ?? false
		self.configFile = settings.value(forKeyPath: configKeyPath) as? String
	}

	mutating func setActive(value: Bool) {
		settings.setValue(value, forKeyPath: activeKeyPath)
		self.isActive = value
	}

	mutating func setConfig(value: String) {
		settings.setValue(value, forKeyPath: configKeyPath)
		self.configFile = value
	}

}
