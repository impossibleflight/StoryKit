//
//  StoryKitTool.swift
//  StoryKitTool
//
//  Created by John Clayton on 1/14/19.
//  Copyright © 2019 Impossible Flight, LLC. All rights reserved.
//

import Foundation
import Utility
import Basic


public protocol Command {
	var command: String { get }
	var overview: String { get }
	init(parser: ArgumentParser)
	func run(with options: ArgumentParser.Result) throws
}

public struct StoryKitTool {
	enum Error: Swift.Error, CustomStringConvertible {
		case missingInputDirectory(String)
		case missingOutputDirectory(String)

		var description: String {
			switch self {
			case let .missingInputDirectory(directory):
				return "Input directory does not exist or is not a directory. '\(directory)'"
			case let .missingOutputDirectory(directory):
				return "Output directory does not exist or is not a directory. '\(directory)'"
			}
		}
	}

	let fm = FileManager()
	private(set) var commands = [Command]()
	let parser: ArgumentParser
	private let versionOption: OptionArgument<Bool>

	public init(usage: String, overview: String){
		parser = ArgumentParser(usage: usage, overview: overview)
		versionOption = parser.add(option: "--version", shortName: "-v", kind: Bool.self)
	}

	public mutating func register(command: Command.Type) {
		commands.append(command.init(parser: parser))
	}

	public func run(arguments: [String]) throws {
		do {
			let options = try parser.parse(arguments)
			if let _ = options.get(versionOption) {
				if let versionCommand = commands.first(where: { $0.command == VersionCommand.command }) {
					try versionCommand.run(with: options)
					return
				}
			}

			guard let subparser = options.subparser(parser), let command = commands.first(where: { $0.command == subparser }) else {
				parser.printUsage(on: stdoutStream)
				return
			}

			try command.run(with: options)
		} catch let error as ArgumentParserError {
			throw FatalError.withUnderlying(error, ErrorCode.argumentError)
		} catch let error as StoryKitTool.Error {
			throw FatalError.withUnderlying(error, ErrorCode.executionError)
		} catch let error as UpdateCommand.Error {
			throw FatalError.withUnderlying(error, ErrorCode.updateError)
		} catch let error as StoryboardLoader.Error {
			throw FatalError.withUnderlying(error, ErrorCode.storyboardLoadingError)
		} catch let error as StoryboardBuilder.Error {
			throw FatalError.withUnderlying(error, ErrorCode.storyboardParsingError)
		} catch  {
			throw FatalError.withUnderlying(error, ErrorCode.unknownError)
		}
	}
}

