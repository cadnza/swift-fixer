//
//  Version.swift
//  Swift Fixer
//
//  Created by Jonathan Dayley on 2/1/23.
//

import Foundation

struct Version: Decodable {

	private enum Keys: CodingKey {
		case exec
		case version
	}

	let exec: String
	let version: String

}
