//
//  StoryboardWriter.swift
//  StoryKitTool
//
//  Created by John Clayton on 1/19/19.
//  Copyright © 2019 Impossible Flight, LLC. All rights reserved.
//

import Foundation
import Stencil

extension Error {
	var underlyingError: Error? {
		let userInfo: [String:Any] = (self as NSError).userInfo
		return userInfo[NSUnderlyingErrorKey] as? Error
	}
}

class StoryboardWriter {
	enum Error: Swift.Error, CustomStringConvertible {
		case templateError(file: String, error: Swift.Error)
		case overwriteError(file: String)
		case errorReadingFile(file: String, error: Swift.Error)
		case malformedFile(file: String, reason: String)
		case writeError(file: String, error: Swift.Error)
		var description: String {
			switch self {
			case let .templateError(template, error):
				return "Fatal error generating code from template. '\(template)' (\(error))"
			case let .overwriteError(file):
				return "Code generation would overwrite existing file and --force-overwrite is not set. '\(file)'"
			case let .errorReadingFile(file, error):
				return "Failed to open file for updating. `\(file)` (\(error)) "
			case let .malformedFile(file, reason):
				return "Malformed input file. '\(file)' (\(reason))"
			case let .writeError(file, error):
				return "Failed to write to file. '\(file)' (\(error))"
			}
		}
	}
	let storyboard: Storyboard!
	init(storyboard: Storyboard) {
		self.storyboard = storyboard
	}

	func write(outputDirectory: URL, forceOverwrite: Bool, dryRun: Bool) throws {
		struct StandardOutStream: TextOutputStream {
			mutating func write(_ string: String) {
				print(string)
			}
		}
		var stdoutStream = StandardOutStream()
		try write(outputDirectory: outputDirectory, forceOverwrite: forceOverwrite, dryRun: dryRun, outputStream: &stdoutStream)
	}

	func write<Target>(outputDirectory: URL, forceOverwrite: Bool, dryRun: Bool, outputStream: inout Target) throws where Target: TextOutputStream {
		let fileName = "\(storyboard.name).swift"
		let filePath = (outputDirectory.path as NSString).appendingPathComponent(fileName)

		let template = Template(templateString: __template__)
		let storyboardContext = storyboard.templateContext
		do {
			let _main = try Template(templateString: __main__).render(storyboardContext)
			let _extension = try Template(templateString: __extension__).render(storyboardContext)
			let result: String = try template.render([Keys.main:_main, Keys.extension:_extension])

			guard !dryRun else {
				print("Would write the following to \(filePath):", to: &outputStream)
				print(result, to: &outputStream)
				return
			}

			let fm = FileManager()
			guard forceOverwrite == true || !fm.fileExists(atPath: filePath) else {
				throw Error.overwriteError(file: filePath)
			}

			try result.write(toFile: filePath, atomically: true, encoding: .utf8)

		} catch let error as Stencil.TemplateSyntaxError {
			throw Error.templateError(file: filePath, error: error)
		} catch let error as Error {
			throw error
		} catch {
			throw Error.writeError(file: filePath, error: error)
		}
	}

	func inline(outputDirectory: URL, dryRun: Bool) throws {
		let fileName = "\(storyboard.name).swift"
		let filePath = (outputDirectory.path as NSString).appendingPathComponent(fileName)

		var contents: NSString
		do {
			contents = try String(contentsOfFile: filePath) as NSString
		} catch {
			throw Error.errorReadingFile(file: filePath, error: error)
		}

		let startTag = "// storykit:inline:\(storyboard.name).StoryboardSceneDescriptor"
		let endTag = "// storykit:end"
		let startRange = contents.range(of: startTag)
		let endRange = contents.range(of: endTag)
		guard startRange.location != NSNotFound && endRange.location != NSNotFound else {
			throw Error.malformedFile(file: filePath, reason: "Could not locate start and end annotations.")
		}
		let startLocation = startRange.location
		let length = NSMaxRange(endRange)-startLocation
		let mainRange = NSRange(location: startLocation, length: length)

		let storyboardContext = storyboard.templateContext
		do {
			let _main = try Template(templateString: __main__).render(storyboardContext)
			contents = (contents.replacingCharacters(in: mainRange, with: _main)) as NSString
			guard !dryRun else {
				print("Would write the following to \(filePath):")
				print(contents)
				return
			}
			try contents.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8.rawValue)
		} catch let error as Stencil.TemplateSyntaxError {
			throw Error.templateError(file: filePath, error: error)
		} catch {
			throw Error.writeError(file: filePath, error: error)
		}
	}
}
