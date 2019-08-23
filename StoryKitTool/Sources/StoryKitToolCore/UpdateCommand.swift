//
//  UpdateCommand.swift
//  StoryKitToolCore
//
//  Created by John Clayton on 1/24/19.
//

import Foundation
import class Utility.ArgumentParser
import class Utility.OptionArgument
import enum Utility.ArgumentParserError
import Stencil

public struct UpdateCommand: Command {
	enum Error: Swift.Error, CustomStringConvertible {
		case errorDeletingFile(file: String, error: Swift.Error)

		var description: String {
			switch self {
			case let .errorDeletingFile(file, error):
				return "Failed to delete file. `\(file)` (\(error)) "
			}
		}
	}

	public let command = "update"
	public let overview = "Update generated StoryKit files with the supplied storyboards."
	let inputDirectoryOption: OptionArgument<String>!
	let outputDirectoryOption: OptionArgument<String>!
	let pruneOption: OptionArgument<Bool>
	let dryRunOption: OptionArgument<Bool>

	public init(parser: ArgumentParser) {
		subparser = parser.add(subparser: command, overview: overview)
		pruneOption = subparser.add(option: "--no-prune", shortName: "-p", kind: Bool.self, usage: "Don't remove unused generated files.")
		dryRunOption = subparser.add(option: "--dry-run", shortName: "-y", kind: Bool.self, usage: "Just output what you would generate instead of actually writing out the files.")

		inputDirectoryOption = subparser.add(option: "--input", shortName: "-i", kind: String.self, usage: "The path to the directory containing the storyboards to be used as input. Searched recursively.", completion: .filename)
		outputDirectoryOption = subparser.add(option: "--output", shortName: "-o", kind: String.self, usage: "The path to the directory containing the generated swift sources that are to be updated with the current storyboard data.", completion: .filename)
	}

	public func run(with options: ArgumentParser.Result) throws {
		guard let inputDirectoryPath = options.get(inputDirectoryOption) else {
			throw ArgumentParserError.expectedArguments(subparser, ["--input"])
		}
		guard let outputDirectoryPath = options.get(outputDirectoryOption) else {
			throw ArgumentParserError.expectedArguments(subparser, ["--output"])
		}

		let skipPrune = options.get(pruneOption) ?? false
		let dryRun = options.get(dryRunOption) ?? false

		let workingDirectoryURL = URL(fileURLWithPath: fm.currentDirectoryPath)
		let inputDirectoryURL = URL(fileURLWithPath: inputDirectoryPath, relativeTo: workingDirectoryURL)
		let outputDirectoryURL = URL(fileURLWithPath: outputDirectoryPath, relativeTo: workingDirectoryURL)

		let storyboards = try storyboardLoader.storyboards(fromInputDirectory: inputDirectoryURL)
		try updateCode(forStoryboards: storyboards, outputDirectory: outputDirectoryURL, skipPrune: skipPrune, dryRun: dryRun)
	}

	private func updateCode(forStoryboards storyboards: [String:Storyboard], outputDirectory outputDirectoryURL: URL, skipPrune: Bool, dryRun: Bool) throws {
		let fm = FileManager()
		var orphanedFiles = [URL]()
		let files = try fm.contentsOfDirectory(atPath: outputDirectoryURL.path)
		for file in files {
			let pathURL = outputDirectoryURL.appendingPathComponent(file)
			if storyboards[(pathURL.lastPathComponent as NSString).deletingPathExtension] == nil {
				orphanedFiles.append(pathURL)
			}
		}

		for (name, storyboard) in storyboards {
			let fileURL = outputDirectoryURL.appendingPathComponent("\(name).swift")
			if fm.fileExists(atPath: fileURL.path) {
				let writer = StoryboardWriter(storyboard: storyboard)
				try writer.inline(outputDirectory: outputDirectoryURL, dryRun: dryRun)
			} else {
				let writer = StoryboardWriter(storyboard: storyboard)
				try writer.write(outputDirectory: outputDirectoryURL, forceOverwrite: false, dryRun: dryRun)
			}
		}

		if !skipPrune {
			for file in orphanedFiles {
				do {
					try fm.removeItem(at: file)
				} catch {
					throw Error.errorDeletingFile(file: file.absoluteString, error: error)
				}
			}
		}
	}


	private let subparser: ArgumentParser
	private let fm = FileManager()
	private let storyboardLoader = StoryboardLoader()
}
