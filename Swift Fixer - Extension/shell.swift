//
//  shell.swift
//  Swift Fixer - Extension
//
//  Created by Jonathan Dayley on 1/24/23.
//

import Foundation

func shell(command: String, args: [String]? = []) throws -> String {
	let task = Process()
	let pipe = Pipe()

	task.standardOutput = pipe
	task.standardError = pipe
	task.arguments = args
	task.launchPath = command
	task.standardInput = nil
	do {
		try task.run()
	} catch {
		throw error
	}

	let data = pipe.fileHandleForReading.readDataToEndOfFile()
	let output = String(data: data, encoding: .utf8)!

	return output
}
