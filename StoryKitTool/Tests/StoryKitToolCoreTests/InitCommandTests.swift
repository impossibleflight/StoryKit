import XCTest
import class Foundation.Bundle

@testable import StoryKitToolCore
import class Utility.ArgumentParser
import class Utility.OptionArgument
import enum Utility.ArgumentParserError

final class InitCommandTests: XCTestCase {

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
		let initCommand = InitCommand(parser: parser)

		let args = ["init", "--output", outputDirectoryURL.path]
		let options = try! parser.parse(args)

		var argumentError: Error? = nil
		do {
			try initCommand.run(with: options)
		} catch let error as ArgumentParserError {
			argumentError = error
		} catch {}

		XCTAssertNotNil(argumentError)
	}

	func testFailWithoutOutputOption() {
		let parser = ArgumentParser(usage: "test", overview: "test")
		let initCommand = InitCommand(parser: parser)

		let args = ["init", "--input", inputDirectoryURL.path]
		let options = try! parser.parse(args)

		var argumentError: Error? = nil
		do {
			try initCommand.run(with: options)
		} catch let error as ArgumentParserError {
			argumentError = error
		} catch {}

		XCTAssertNotNil(argumentError)
	}

	func testSucceedWithNecessaryOptions() {
		let parser = ArgumentParser(usage: "test", overview: "test")
		let initCommand = InitCommand(parser: parser)

		let args = ["init", "--input", inputDirectoryURL.path, "--output", outputDirectoryURL.path]
		let options = try! parser.parse(args)

		var argumentError: Error? = nil
		do {
			try initCommand.run(with: options)
		} catch let error as ArgumentParserError {
			argumentError = error
		} catch {}

		XCTAssertNil(argumentError)
	}

	func testSetsForceOverwriteOption() {
		XCTFail("Unimplemented")
	}

	func testSetsDryRunOption() {
		XCTFail("Unimplemented")
	}

}
