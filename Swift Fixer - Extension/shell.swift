//
//  shell.swift
//  Swift Fixer - Extension
//
//  Created by Jonathan Dayley on 1/24/23.
//

import Foundation

func shell(command: String, args: [String] = []) -> (
	status: Int, message: String
) {

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
	do { try task.run() } catch { return (1, "Could not run") }
	task.waitUntilExit()

	// Get exit code
	let code: Int = Int(task.terminationStatus)

	// Capture output
	let data = pipe.fileHandleForReading.readDataToEndOfFile()
	let output = String(data: data, encoding: .utf8)!

	// Return
	return (code, output)
}
