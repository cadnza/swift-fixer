//
//  Settings.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 2/3/23.
//

import Foundation

struct Settings {

	private let appGroupId = "9TVGLBSJNB.group.com.cadnza.swift-fixer"
	private let defaults: UserDefaults

	init() {
		self.defaults = UserDefaults(suiteName: appGroupId)!
	}

	func value(forKey key: String) -> Any? {
		defaults.value(forKey: key)
	}

	func setValue(_ value: Any?, forKey key: String) {
		defaults.setValue(value, forKey: key)
	}

}
