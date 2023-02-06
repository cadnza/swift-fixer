import Foundation

struct Settings {

	let appGroupId = "9TVGLBSJNB.com.cadnza.swift-fixer" // FIXME: Make programmatic

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

	func removeObject(forKey defaultName: String) {
		defaults.removeObject(forKey: defaultName)
	}

}
