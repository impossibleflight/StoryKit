//
//  InitCommand.swift
//  Generator
//
//  Created by John Clayton on 1/21/19.
//  Copyright © 2019 Impossible Flight, LLC. All rights reserved.
//

import Foundation
import class Utility.ArgumentParser
import class Utility.OptionArgument
import enum Utility.ArgumentParserError

public struct InitCommand: Command {
	public let command = "init"
	public let overview = "Generate initial StoryKit files from the supplied storyboards."
	let inputDirectoryOption: OptionArgument<String>!
	let outputDirectoryOption: OptionArgument<String>!
	let forceOverwriteOption: OptionArgument<Bool>
	let dryRunOption: OptionArgument<Bool>

	public init(parser: ArgumentParser) {
		subparser = parser.add(subparser: command, overview: overview)
		forceOverwriteOption = subparser.add(option: "--force-overwrite", shortName: "-f", kind: Bool.self, usage: "If output files exist already overwrite them. Be careful.")
		dryRunOption = subparser.add(option: "--dry-run", shortName: "-y", kind: Bool.self, usage: "Just output what you would generate instead of actually writing out the files.")
		inputDirectoryOption = subparser.add(option: "--input", shortName: "-i", kind: String.self, usage: "The path to the directory containing the storyboards to be used as input. Searched recursively.", completion: .filename)
		outputDirectoryOption = subparser.add(option: "--output", shortName: "-o", kind: String.self, usage: "The path to the directory where generated swift sources should be placed.", completion: .filename)
	}
	
	public func run(with options: ArgumentParser.Result) throws {
		guard let inputDirectoryPath = options.get(inputDirectoryOption) else {
			throw ArgumentParserError.expectedArguments(subparser, ["--input"])
		}
		guard let outputDirectoryPath = options.get(outputDirectoryOption) else {
			throw ArgumentParserError.expectedArguments(subparser, ["--output"])
		}

		let forceOverwrite = options.get(forceOverwriteOption) ?? false
		let dryRun = options.get(dryRunOption) ?? false

		let workingDirectoryURL = URL(fileURLWithPath: fm.currentDirectoryPath)
		let inputDirectoryURL = URL(fileURLWithPath: inputDirectoryPath, relativeTo: workingDirectoryURL)
		let outputDirectoryURL = URL(fileURLWithPath: outputDirectoryPath, relativeTo: workingDirectoryURL)

		let storyboards = try storyboardLoader.storyboards(fromInputDirectory: inputDirectoryURL)
		try generateCode(forStoryboards: Array(storyboards.values), outputDirectory: outputDirectoryURL, forceOverwrite: forceOverwrite, dryRun: dryRun)
	}

	private func generateCode(forStoryboards storyboards: [Storyboard], outputDirectory outputDirectoryURL: URL, forceOverwrite: Bool, dryRun: Bool) throws {
		try fm.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true, attributes: nil)
		for storyboard in storyboards {
			let writer = StoryboardWriter(storyboard: storyboard)
			do {
				try writer.write(outputDirectory: outputDirectoryURL, forceOverwrite: forceOverwrite, dryRun: dryRun)
			} catch let error as StoryboardWriter.Error {
				switch error {
				case .overwriteError:
					print(error)
					return
				default:
					throw error
				}
			}
		}
	}

	private let subparser: ArgumentParser
	private let fm = FileManager()
	private let storyboardLoader = StoryboardLoader()
}


