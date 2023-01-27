//
//  DataSource.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 1/26/23.
//

import Foundation

struct DataSource {

	let contents: [ExecutableStep]

	init() {
		let jsonfile = "commands"
		let url = Bundle.main.url(forResource: jsonfile, withExtension: "json")
		let data = try! Data(contentsOf: url!)
		self.contents = try! JSONDecoder().decode([ExecutableStep].self, from: data)
	}

}
