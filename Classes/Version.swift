import Foundation

struct Version: Decodable {

	private enum Keys: CodingKey {
		case exec
		case version
	}

	let exec: String
	let version: String

}
