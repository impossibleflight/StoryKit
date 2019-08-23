//
//  StoryboardLoaderTests.swift
//  StoryKitToolCoreTests
//
//  Created by John Clayton on 1/24/19.
//

import XCTest

@testable import StoryKitToolCore
class StoryboardLoaderTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testFailsToLoadStoryboardsFromNonexistentDirectory() {
		let storyboardLoader = StoryboardLoader()

		var inputDirectoryError: Error? = nil
		var trappedError: Error? = nil
		do {
			_ = try storyboardLoader.storyboards(fromInputDirectory: URL(fileURLWithPath: "/foo"))
		} catch let error as StoryKitTool.Error {
			inputDirectoryError = error
		} catch {
			trappedError = error
		}
		XCTAssertNotNil(inputDirectoryError)
		XCTAssertNil(trappedError)
	}

	func testLoadsViewController() {
		let bundle = Bundle(for: type(of: self))
		let resourcesURL = URL(fileURLWithPath: (bundle.resourcePath! as NSString).appendingPathComponent("Storyboards/Controller"))
		let storyboardLoader = StoryboardLoader()

		var storyboards: [String:Storyboard] = [:]
		var trappedError: Error? = nil
		do {
			storyboards = try storyboardLoader.storyboards(fromInputDirectory: resourcesURL)
		} catch {
			trappedError = error
		}

		XCTAssertNil(trappedError)
		XCTAssertEqual(storyboards.count, 1, "Wrong number of storyboards!")
		let storyboard = storyboards["Storyboard"]
		XCTAssertNotNil(storyboard)
		XCTAssertEqual(storyboard!.controllers.count, 1, "Wrong number of controllers!")
		let controller = storyboard!.sceneControllers.first
		XCTAssertNotNil(controller)
		XCTAssertEqual(controller!.customClass, "BasicViewController", "Wrong controller class!")
		XCTAssertEqual(controller!.storyboardIdentifier, "basic", "Wrong storyboard identifier!")
		XCTAssertEqual(controller!.title, "Basic", "Wrong storyboard title!")
		XCTAssertNotNil(storyboard!.initialViewController)
		XCTAssertEqual(storyboard!.initialViewController!, controller!, "Wrong initial view controller!")
	}

	func testFailsToLoadWhenMissingStoryboardIdentifier() {
		let bundle = Bundle(for: type(of: self))
		let resourcesURL = URL(fileURLWithPath: (bundle.resourcePath! as NSString).appendingPathComponent("Storyboards/Malformed/MissingIdentifier"))
		let storyboardLoader = StoryboardLoader()

		var storyboardError: Error? = nil
		var trappedError: Error? = nil
		do {
			_ = try storyboardLoader.storyboards(fromInputDirectory: resourcesURL)
		} catch let error as StoryboardBuilder.Error {
			switch error {
			case .missingStoryboardIdentifier:
				storyboardError = error
			default:
				break;
			}
		} catch {
			trappedError = error
		}

		XCTAssertNil(trappedError)
		XCTAssertNotNil(storyboardError)
	}

	func testFailsToLoadWhenRestorationIdentifierMismatch() {
		let bundle = Bundle(for: type(of: self))
		let resourcesURL = URL(fileURLWithPath: (bundle.resourcePath! as NSString).appendingPathComponent("Storyboards/Malformed/MismatchedIdentifiers"))
		let storyboardLoader = StoryboardLoader()

		var storyboardError: Error? = nil
		var trappedError: Error? = nil
		do {
			_ = try storyboardLoader.storyboards(fromInputDirectory: resourcesURL)
		} catch let error as StoryboardBuilder.Error {
			switch error {
			case .restorationIdentifierMismatch:
				storyboardError = error
			default:
				break;
			}
		} catch {
			trappedError = error
		}

		XCTAssertNil(trappedError)
		XCTAssertNotNil(storyboardError)
	}

	func testLoadsMainStoryboardWithChildReferences() {
		let bundle = Bundle(for: type(of: self))
		let resourcesURL = URL(fileURLWithPath: (bundle.resourcePath! as NSString).appendingPathComponent("Storyboards/Main"))
		let storyboardLoader = StoryboardLoader()

		var storyboards: [String:Storyboard] = [:]
		var trappedError: Error? = nil
		do {
			storyboards = try storyboardLoader.storyboards(fromInputDirectory: resourcesURL)
		} catch {
			trappedError = error
		}

		XCTAssertNil(trappedError)
		XCTAssertEqual(storyboards.count, 3, "Wrong number of storyboards!")
		let mainStoryboard = storyboards["Main"]
		XCTAssertNotNil(mainStoryboard)

		XCTAssertEqual(mainStoryboard!.sceneControllers.count, 3, "Wrong number of controllers in main storyboard!")

		let oneStoryboard = storyboards["One"]
		XCTAssertNotNil(oneStoryboard)
		let twoStoryboard = storyboards["Two"]
		XCTAssertNotNil(twoStoryboard)

		XCTAssertEqual(oneStoryboard!.sceneControllers.count, 2, "Wrong number of controllers in storyboard One!")
		XCTAssertEqual(twoStoryboard!.sceneControllers.count, 5, "Wrong number of controllers in storyboard Two!")
	}

	func testResolvesControllerRelationships() {
		let bundle = Bundle(for: type(of: self))
		let resourcesURL = URL(fileURLWithPath: (bundle.resourcePath! as NSString).appendingPathComponent("Storyboards/Main"))
		let storyboardLoader = StoryboardLoader()

		var storyboards: [String:Storyboard] = [:]
		var trappedError: Error? = nil
		do {
			storyboards = try storyboardLoader.storyboards(fromInputDirectory: resourcesURL)
		} catch {
			trappedError = error
		}
		XCTAssertNil(trappedError)
		let mainStoryboard = storyboards["Main"]
		XCTAssertNotNil(mainStoryboard)
		let rootController = mainStoryboard!.sceneController(identifiedBy: "root")
		XCTAssertNotNil(rootController)
		XCTAssertTrue(rootController!.isRootController, "Root controller should be root controller!")
		XCTAssertTrue(rootController!.isContainerScoped, "Root controller should be container scoped!")
		let rootRelationships = rootController!.relationships
		XCTAssertEqual(rootRelationships.count, 2)
		for relationship in rootRelationships {
			XCTAssertEqual(relationship.kind, .viewControllers)
			let destination = relationship.destinationController
			XCTAssertNotNil(destination)
			XCTAssertTrue(destination!.isContainerScoped, "Child controllers should be container scoped!")
		}
		let firstViewController = (rootRelationships.first!.destinationController as? SceneController)
		XCTAssertNotNil(firstViewController)
		let firstViewControllerRootControllerRelationship = firstViewController?.relationships.first
		XCTAssertNotNil(firstViewControllerRootControllerRelationship)
		let firstViewControllerRootController = (firstViewControllerRootControllerRelationship?.destinationController as? SceneControllerPlaceholder)
		XCTAssertNotNil(firstViewControllerRootController)
		XCTAssertTrue(firstViewControllerRootController!.isContainerScoped, "Root child should be container scoped!")
		let referencedIdentifier = firstViewControllerRootController!.referencedIdentifier
		XCTAssertEqual(referencedIdentifier, "one")
	}

	func testLoadsPlaceholders() {
		let bundle = Bundle(for: type(of: self))
		let resourcesURL = URL(fileURLWithPath: (bundle.resourcePath! as NSString).appendingPathComponent("Storyboards/Placeholders"))
		let storyboardLoader = StoryboardLoader()

		var storyboards: [String:Storyboard] = [:]
		var trappedError: Error? = nil
		do {
			storyboards = try storyboardLoader.storyboards(fromInputDirectory: resourcesURL)
		} catch {
			trappedError = error
		}

		XCTAssertNil(trappedError)
		XCTAssertEqual(storyboards.count, 2, "Wrong number of storyboards!")
		let root = storyboards["Root"]
		XCTAssertNotNil(root)
		XCTAssertEqual(root!.controllers.count, 4, "Wrong number of controllers!")

		let placeholders = root!.placeholders
		XCTAssertEqual(placeholders.count, 2, "Wrong number of placeholders!")

		for placeholder in placeholders {
			XCTAssertNotNil(placeholder.referencedController)
		}
	}

	func testLoadsControllerWithInputSignature() {
		let bundle = Bundle(for: type(of: self))
		let resourcesURL = URL(fileURLWithPath: (bundle.resourcePath! as NSString).appendingPathComponent("Storyboards/Input"))
		let storyboardLoader = StoryboardLoader()

		var storyboards: [String:Storyboard] = [:]
		var trappedError: Error? = nil
		do {
			storyboards = try storyboardLoader.storyboards(fromInputDirectory: resourcesURL)
		} catch {
			trappedError = error
		}

		XCTAssertNil(trappedError)
		let storyboard = storyboards["Storyboard"]
		XCTAssertNotNil(storyboard)
		let controller = storyboard!.controllers.first
		XCTAssertNotNil(controller)
		XCTAssertEqual(controller!.inputSignature, "(identifier: String)", "Wrong input signature!")
		XCTAssertEqual(controller!.inputLabel, "identifier", "Wrong input label!")
		XCTAssertEqual(controller!.inputTypeName, "String", "Wrong input type!")
	}

}
