//
//  VersionCommand.swift
//  StoryKitToolCore
//
//  Created by John Clayton on 1/23/19.
//

import Foundation
import class Utility.ArgumentParser
import class Utility.OptionArgument
import enum Utility.ArgumentParserError

private let _command = "version"

public struct VersionCommand: Command {
	public static var command = _command
	public let command = _command
	public let overview = "Returns the storykit tool version."
	let fm = FileManager()

	public init(parser: ArgumentParser) {
		subparser = parser.add(subparser: command, overview: overview)
	}

	public func run(with options: ArgumentParser.Result) throws {
		print("StoryKitToolCore version \(Version.version) (\(Version.bundleVersion))")
	}

	private let subparser: ArgumentParser
}
