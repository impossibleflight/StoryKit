//
//  UpdateCommandTests.swift
//  StoryKitToolCoreTests
//
//  Created by John Clayton on 2/13/19.
//

import XCTest
import class Foundation.Bundle

@testable import StoryKitToolCore
import class Utility.ArgumentParser
import class Utility.OptionArgument
import enum Utility.ArgumentParserError

class UpdateCommandTests: XCTestCase {

	let testHelper = TestHelper()
	var inputDirectoryURL: URL = URL(fileURLWithPath: "/tmp/\(InitCommandTests.self)/input")
	var outputDirectoryURL: URL = URL(fileURLWithPath: "/tmp/\(InitCommandTests.self)/output")
	var mainStoryboardFixturesURL: URL!
	var generatedCodeFixturesURL: URL!

	override func setUp() {
		let bundle = Bundle(for: type(of: self))
		let resourcesURL = URL(fileURLWithPath: bundle.resourcePath!)
		mainStoryboardFixturesURL = resourcesURL.appendingPathComponent("Storyboards/Main")
		generatedCodeFixturesURL = resourcesURL.appendingPathComponent("Generated")

		let fm = FileManager()
		if fm.fileExists(atPath: outputDirectoryURL.path) {
			do {
				try testHelper.tearDown(directory: outputDirectoryURL)
			} catch {
				XCTFail(error.localizedDescription)
			}
		}
		do {
			try testHelper.setup(directory: outputDirectoryURL)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}

	func testFailWithoutInputOption() {
		let parser = ArgumentParser(usage: "test", overview: "test")
		let updateCommand = UpdateCommand(parser: parser)

		let args = ["update", "--output", outputDirectoryURL.path]		
		let options = try! parser.parse(args)

		var argumentError: Error? = nil
		do {
			try updateCommand.run(with: options)
		} catch let error as ArgumentParserError {
			argumentError = error
		} catch {}

		XCTAssertNotNil(argumentError)
	}

	func testFailWithoutOutputOption() {
		let parser = ArgumentParser(usage: "test", overview: "test")
		let updateCommand = UpdateCommand(parser: parser)

		let args = ["update", "--input", inputDirectoryURL.path]
		let options = try! parser.parse(args)

		var argumentError: Error? = nil
		do {
			try updateCommand.run(with: options)
		} catch let error as ArgumentParserError {
			argumentError = error
		} catch {}

		XCTAssertNotNil(argumentError)
	}

	func testpropertlyConfiguredGivenNecessaryOptions() {
		let parser = ArgumentParser(usage: "test", overview: "test")
		let updateCommand = UpdateCommand(parser: parser)

		let args = ["update", "--input", inputDirectoryURL.path, "--output", outputDirectoryURL.path]
		let options = try! parser.parse(args)

		var argumentError: Error? = nil
		do {
			try updateCommand.run(with: options)
		} catch let error as ArgumentParserError {
			argumentError = error
		} catch {}

		XCTAssertNil(argumentError)

		let dryRun = options.get(updateCommand.dryRunOption) ?? false
		XCTAssertFalse(dryRun)

		let skipPrune = options.get(updateCommand.pruneOption) ?? false
		XCTAssertFalse(skipPrune)
	}

	func testSetsDryRunOption() {
		let parser = ArgumentParser(usage: "test", overview: "test")
		let updateCommand = UpdateCommand(parser: parser)

		let args = ["update"
			, "--input", inputDirectoryURL.path
			, "--output", outputDirectoryURL.path
			, "--dry-run"]
		let options = try! parser.parse(args)

		var argumentError: Error? = nil
		do {
			try updateCommand.run(with: options)
		} catch let error as ArgumentParserError {
			argumentError = error
		} catch {}

		XCTAssertNil(argumentError)

		let dryRun = options.get(updateCommand.dryRunOption) ?? false
		XCTAssertTrue(dryRun)
	}

	func testUpdatesExistingAndGeneratesMissingFilesOnUpdate() {
		let parser = ArgumentParser(usage: "test", overview: "test")
		let updateCommand = UpdateCommand(parser: parser)

		let args = ["update", "--input", inputDirectoryURL.path, "--output", outputDirectoryURL.path]
		let options = try! parser.parse(args)

		XCTAssertNoThrow(try updateCommand.run(with: options))
	}

	func testPrunesOrphanedFilesOnUpdate() {
		XCTFail("Unimplemented")
	}
}
