//
//  shell.swift
//  Swift Fixer - Extension
//
//  Created by Jonathan Dayley on 1/24/23.
//

import Foundation

enum codeError: Error {
	case general
}

func shell(command: String, args: [String] = []) throws -> String {
	let task = Process()
	let pipe = Pipe()

	task.standardOutput = pipe
	task.standardError = pipe
	task.arguments = args
	task.launchPath = command
	task.standardInput = nil
	try task.run()
	task.waitUntilExit()

	let code: Int = Int(task.terminationStatus)

	if(code != 0){
		throw codeError.general
	}

	let data = pipe.fileHandleForReading.readDataToEndOfFile()
	let output = String(data: data, encoding: .utf8)!

	return output
}
