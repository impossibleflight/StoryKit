//
//  TestHelper.swift
//  StoryKitToolCoreTests
//
//  Created by John Clayton on 2/14/19.
//

import Foundation

class TestHelper {
	func copy(directoryContentsAt sourceDirectoryURL: URL, toDirectory destinationDirectoryURL: URL) throws {
		let fm = FileManager()
		for file in try fm.contentsOfDirectory(atPath: sourceDirectoryURL.path) {
			let source = sourceDirectoryURL.appendingPathComponent(file)
			let destination = destinationDirectoryURL.appendingPathComponent(file)
			try fm.copyItem(at: source, to: destination)
		}
	}

	func setup(directory directoryURL: URL) throws {
		let fm = FileManager()
		try fm.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
	}

	func tearDown(directory directoryURL: URL) throws {
		let fm = FileManager()
		try fm.removeItem(at: directoryURL)
	}
}
