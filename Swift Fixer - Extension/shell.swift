//
//  shell.swift
//  Swift Fixer - Extension
//
//  Created by Jonathan Dayley on 1/24/23.
//

import Foundation

enum codeError: Error {
	case general
	case commandNotExecutable
}

func shell(command: String, args: [String] = []) throws -> [Int: String] {

	// Open process and pipe
	let task = Process()
	let pipe = Pipe()

	// Set stdin and stderr
	task.standardOutput = pipe
	task.standardError = pipe

	// Set arguments
	task.arguments = args

	// Set launch path
	task.launchPath = command

	// Initialize stdin
	task.standardInput = nil

	// Run task
	try task.run()
	task.waitUntilExit()

	// Get exit code
	let code: Int = Int(task.terminationStatus)

	// Throw error on bad exit code
	switch code {
		case 1:
			throw codeError.general
		case 126:
			throw codeError.commandNotExecutable
		default:
			break
	}

	// Capture data
	let data = pipe.fileHandleForReading.readDataToEndOfFile()
	let output = String(data: data, encoding: .utf8)!

	// Return
	return [code: output]
}
