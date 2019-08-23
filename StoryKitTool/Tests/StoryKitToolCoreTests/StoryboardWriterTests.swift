//
//  let writer = StoryboardWriter(storyboard: storyboard) 			let writer = StoryboardWriter(storyboard: storyboard) StoryboardWriterTests.swift
//  StoryKitToolCoreTests
//
//  Created by John Clayton on 2/14/19.
//

import XCTest
@testable import StoryKitToolCore

class StoryboardWriterTests: XCTestCase {

	let testHelper = TestHelper()
	var inputDirectoryURL: URL = URL(fileURLWithPath: "/tmp/\(InitCommandTests.self)/input")
	var outputDirectoryURL: URL = URL(fileURLWithPath: "/tmp/\(InitCommandTests.self)/output")
	var mainStoryboardFixturesURL: URL!
	var modifiedMainStoryboardFixturesURL: URL!
	var mainGeneratedCodeFixturesURL: URL!
	var mainModifiedGeneratedCodeFixturesURL: URL!

	override func setUp() {
		let bundle = Bundle(for: type(of: self))
		let resourcesURL = URL(fileURLWithPath: bundle.resourcePath!)
		mainStoryboardFixturesURL = resourcesURL.appendingPathComponent("Storyboards/Main")
		modifiedMainStoryboardFixturesURL = resourcesURL.appendingPathComponent("Storyboards/Main-Modified")
		mainGeneratedCodeFixturesURL = resourcesURL.appendingPathComponent("Generated/Main")
		mainModifiedGeneratedCodeFixturesURL = resourcesURL.appendingPathComponent("Generated/Main-Modified")

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

	func testThrowsWithoutOverwritingExistingFilesWhenOverrideNotSet() {
		let fm = FileManager()
		do {
			try testHelper.copy(directoryContentsAt: mainGeneratedCodeFixturesURL, toDirectory: outputDirectoryURL)
		} catch  {
			XCTFail(error.localizedDescription)
		}

		var storyboard: Storyboard?
		do {
			let loader = StoryboardLoader()
			let storyboards = try loader.storyboards(fromInputDirectory: modifiedMainStoryboardFixturesURL)
			storyboard = storyboards["Main"]
		} catch {
			XCTFail(error.localizedDescription)
		}
		XCTAssertNotNil(storyboard)

		let writer = StoryboardWriter(storyboard: storyboard!)
		var writerError: StoryboardWriter.Error?
		do {
			try writer.write(outputDirectory: outputDirectoryURL, forceOverwrite: false, dryRun: false)
		} catch let error as StoryboardWriter.Error {
			switch error {
			case .overwriteError:
				writerError = error
			default:
				break;
			}
		} catch {}

		XCTAssertNotNil(writerError)


		let generated_main_swift_URL = outputDirectoryURL.appendingPathComponent("Main.swift")
		XCTAssertTrue(fm.fileExists(atPath: generated_main_swift_URL.path), "Main.swift missing!")

		let fixture_main_swift_URL = mainGeneratedCodeFixturesURL.appendingPathComponent("Main.swift")
		XCTAssertTrue(fm.contentsEqual(atPath: generated_main_swift_URL.path, andPath: fixture_main_swift_URL.path), "Generated Main.swift was modified!")
	}

	func testOverwritesExistingFileWhenForceOverwriteIsSet() {
		do {
			try testHelper.copy(directoryContentsAt: mainGeneratedCodeFixturesURL, toDirectory: outputDirectoryURL)
		} catch  {
			XCTFail(error.localizedDescription)
		}

		var storyboard: Storyboard?
		do {
			let loader = StoryboardLoader()
			let storyboards = try loader.storyboards(fromInputDirectory: modifiedMainStoryboardFixturesURL)
			storyboard = storyboards["Main"]
		} catch {
			XCTFail(error.localizedDescription)
		}
		XCTAssertNotNil(storyboard)

		let writer = StoryboardWriter(storyboard: storyboard!)
		var writerError: StoryboardWriter.Error?
		do {
			try writer.write(outputDirectory: outputDirectoryURL, forceOverwrite: true, dryRun: false)
		} catch let error as StoryboardWriter.Error {
			switch error {
			case .overwriteError:
				writerError = error
			default:
				break;
			}
		} catch {}

		XCTAssertNil(writerError)

		let fm = FileManager()

		let generated_main_swift_URL = outputDirectoryURL.appendingPathComponent("Main.swift")
		XCTAssertTrue(fm.fileExists(atPath: generated_main_swift_URL.path), "Main.swift missing!")

		let fixture_main_swift_URL = mainGeneratedCodeFixturesURL.appendingPathComponent("Main.swift")
		XCTAssertFalse(fm.contentsEqual(atPath: generated_main_swift_URL.path, andPath: fixture_main_swift_URL.path), "Generated Main.swift not modified!")
	}

	func testOutputsResultsAndBailsWhenDryRunSet() {
		var storyboard: Storyboard?
		do {
			let loader = StoryboardLoader()
			let storyboards = try loader.storyboards(fromInputDirectory: modifiedMainStoryboardFixturesURL)
			storyboard = storyboards["Main"]
		} catch {
			XCTFail(error.localizedDescription)
		}
		XCTAssertNotNil(storyboard)

		let writer = StoryboardWriter(storyboard: storyboard!)
		var output = ""
		XCTAssertNoThrow(try writer.write(outputDirectory: outputDirectoryURL, forceOverwrite: false, dryRun: true, outputStream: &output))



		let fm = FileManager()

		let generated_main_swift_URL = outputDirectoryURL.appendingPathComponent("Main.swift")
		XCTAssertFalse(fm.fileExists(atPath: generated_main_swift_URL.path), "Main.swift exists!")

		let rangeOfOutput = (output as NSString).range(of: "Would write the following to \(generated_main_swift_URL.path):")
		XCTAssertTrue(rangeOfOutput.location != NSNotFound, "Incorrect output!")
	}

	func testGeneratesCorrectCodeForMain() {
		var storyboards = [String:Storyboard]()
		do {
			let loader = StoryboardLoader()
			storyboards = try loader.storyboards(fromInputDirectory: mainStoryboardFixturesURL)
		} catch {
			XCTFail(error.localizedDescription)
		}
		XCTAssertEqual(storyboards.count, 3)

		for (_,storyboard) in storyboards {
			let writer = StoryboardWriter(storyboard: storyboard)
			XCTAssertNoThrow(try writer.write(outputDirectory: outputDirectoryURL, forceOverwrite: false, dryRun: false))
		}

		let fm = FileManager()

		let generated_main_swift_URL = outputDirectoryURL.appendingPathComponent("Main.swift")
		let generated_one_swift_URL = outputDirectoryURL.appendingPathComponent("One.swift")
		let generated_two_swift_URL = outputDirectoryURL.appendingPathComponent("Two.swift")

		XCTAssertTrue(fm.fileExists(atPath: generated_main_swift_URL.path), "Main.swift missing!")
		XCTAssertTrue(fm.fileExists(atPath: generated_one_swift_URL.path), "One.swift missing!")
		XCTAssertTrue(fm.fileExists(atPath: generated_two_swift_URL.path), "Two.swift missing!")


		let fixture_main_swift_URL = mainGeneratedCodeFixturesURL.appendingPathComponent("Main.swift")
		let fixture_one_swift_URL = mainGeneratedCodeFixturesURL.appendingPathComponent("One.swift")
		let fixture_two_swift_URL = mainGeneratedCodeFixturesURL.appendingPathComponent("Two.swift")

		let generated_main_swift_content = try? String(contentsOf: generated_main_swift_URL)
		let fixture_main_swift_content = try? String(contentsOf: fixture_main_swift_URL)
		XCTAssertEqual(generated_main_swift_content, fixture_main_swift_content, "Generated Main.swift not correct!")

		let generated_one_swift_content = try? String(contentsOf: generated_one_swift_URL)
		let fixture_one_swift_content = try? String(contentsOf: fixture_one_swift_URL)
		XCTAssertEqual(generated_one_swift_content, fixture_one_swift_content, "Generated One.swift not correct!")

		let generated_two_swift_content = try? String(contentsOf: generated_two_swift_URL)
		let fixture_two_swift_content = try? String(contentsOf: fixture_two_swift_URL)
		XCTAssertEqual(generated_two_swift_content, fixture_two_swift_content, "Generated Two.swift not correct!")
	}

	func testCorrectlyModifiesInlinedCodeForMain() {
		do {
			try testHelper.copy(directoryContentsAt: mainGeneratedCodeFixturesURL, toDirectory: outputDirectoryURL)
		} catch  {
			XCTFail(error.localizedDescription)
		}

		let fm = FileManager()

		let generated_main_swift_URL = outputDirectoryURL.appendingPathComponent("Main.swift")
		let generated_one_swift_URL = outputDirectoryURL.appendingPathComponent("One.swift")
		let generated_two_swift_URL = outputDirectoryURL.appendingPathComponent("Two.swift")

		XCTAssertTrue(fm.fileExists(atPath: generated_main_swift_URL.path), "Main.swift missing!")
		XCTAssertTrue(fm.fileExists(atPath: generated_one_swift_URL.path), "One.swift missing!")
		XCTAssertTrue(fm.fileExists(atPath: generated_two_swift_URL.path), "Two.swift missing!")

		var storyboards = [String:Storyboard]()
		do {
			let loader = StoryboardLoader()
			storyboards = try loader.storyboards(fromInputDirectory: modifiedMainStoryboardFixturesURL)
		} catch {
			XCTFail(error.localizedDescription)
		}
		XCTAssertEqual(storyboards.count, 4)

		for (name,storyboard) in storyboards {
			let fileURL = outputDirectoryURL.appendingPathComponent("\(name).swift")
			let writer = StoryboardWriter(storyboard: storyboard)
			if fm.fileExists(atPath: fileURL.path) {
				XCTAssertNoThrow(try writer.inline(outputDirectory: outputDirectoryURL, dryRun: false))
			} else {
				XCTAssertNoThrow(try writer.write(outputDirectory: outputDirectoryURL, forceOverwrite: true, dryRun: false))
			}
		}

		let generated_three_swift_URL = outputDirectoryURL.appendingPathComponent("Three.swift")

		let fixture_main_modified_swift_URL = mainModifiedGeneratedCodeFixturesURL.appendingPathComponent("Main.swift")
		let fixture_one_modified_swift_URL = mainModifiedGeneratedCodeFixturesURL.appendingPathComponent("One.swift")
		let fixture_two_modified_swift_URL = mainModifiedGeneratedCodeFixturesURL.appendingPathComponent("Two.swift")
		let fixture_three_modified_swift_URL = mainModifiedGeneratedCodeFixturesURL.appendingPathComponent("Three.swift")


		let generated_main_swift_content = try? String(contentsOf: generated_main_swift_URL)
		let fixture_main_modified_swift_content = try? String(contentsOf: fixture_main_modified_swift_URL)
		//FIXME: the manually edited content can differ, only check the autogenerated code
		XCTAssertEqual(generated_main_swift_content, fixture_main_modified_swift_content, "Updated Main.swift not correct!")

		let generated_one_swift_content = try? String(contentsOf: generated_one_swift_URL)
		let fixture_one_modified_swift_content = try? String(contentsOf: fixture_one_modified_swift_URL)
		XCTAssertEqual(generated_one_swift_content, fixture_one_modified_swift_content, "Updated One.swift not correct!")

		let generated_two_swift_content = try? String(contentsOf: generated_two_swift_URL)
		let fixture_two_modified_swift_content = try? String(contentsOf: fixture_two_modified_swift_URL)
		XCTAssertEqual(generated_two_swift_content, fixture_two_modified_swift_content, "Updated Two.swift not correct!")

		let generated_three_swift_content = try? String(contentsOf: generated_three_swift_URL)
		let fixture_three_modified_swift_content = try? String(contentsOf: fixture_three_modified_swift_URL)
		XCTAssertEqual(generated_three_swift_content, fixture_three_modified_swift_content, "Generated Three.swift not correct!")
	}

}


