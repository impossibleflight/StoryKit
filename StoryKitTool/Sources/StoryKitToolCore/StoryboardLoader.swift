//
//  StoryboardLoader.swift
//  StoryKitToolCore
//
//  Created by John Clayton on 1/24/19.
//

import Foundation

struct StoryboardLoader {
	enum Error: Swift.Error, CustomStringConvertible {
		case missingInputEnumerator(String)
		var description: String {
			switch self {
			case let .missingInputEnumerator(directory):
				return "Failed to get enumerator for input directory. '\(directory)'"
			}
		}
	}

	let fm = FileManager()

	func storyboards(fromInputDirectory inputDirectoryURL: URL) throws -> [String:Storyboard] {
		guard let attributes = try? inputDirectoryURL.resourceValues(forKeys: [.isDirectoryKey]), let isDirectory = attributes.isDirectory, isDirectory == true else  {
			throw StoryKitTool.Error.missingInputDirectory(inputDirectoryURL.path)
		}
		let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .typeIdentifierKey, .nameKey]
		guard let enumerator = fm.enumerator(at: inputDirectoryURL, includingPropertiesForKeys: resourceKeys, options: [.skipsHiddenFiles, .skipsPackageDescendants], errorHandler: nil) else {
			throw Error.missingInputEnumerator(inputDirectoryURL.path)
		}

		var storyboards = [String:Storyboard]()
		for case let fileURL as NSURL in enumerator {
			guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys)
				, let isDirectory = resourceValues[.isDirectoryKey] as? Bool
				, isDirectory == false
				, let filename = resourceValues[.nameKey] as? NSString
				, let typeIdentifier = resourceValues[.typeIdentifierKey] as? String
				else {
					continue
			}

			if typeIdentifier == "com.apple.dt.interfacebuilder.document.storyboard" {
				let storyboard = try StoryboardBuilder().build(name: filename.deletingPathExtension, fromURL: fileURL as URL)
				storyboards[storyboard.name] = storyboard
			}
		}

		resolvePlaceholders(inStoryboards: storyboards)
		resolveRelationships(inStoryboards: storyboards)
		
		return storyboards
	}

	func resolvePlaceholders(inStoryboards storyboards: [String:Storyboard]) {
		let placeholders = storyboards.reduce([SceneControllerPlaceholder]()) { (placeholders, entry) -> [SceneControllerPlaceholder] in
			let (_, storyboard) = entry
			return placeholders + storyboard.placeholders
		}

		for placeholder in placeholders {
			if let storyboard = storyboards[placeholder.storyboardName] {
				if let referencedIdentifier = placeholder.referencedIdentifier, let controller = storyboard.sceneController(identifiedBy: referencedIdentifier) {
					placeholder.resolve(toController: controller)
				} else if let initialController = storyboard.initialViewController {
					placeholder.resolve(toController: initialController)
				}
			}
		}
	}

	func resolveRelationships(inStoryboards storyboards: [String:Storyboard]) {
		let controllersByID = Array(storyboards.values).reduce([String:Controller]()) { controllersByID, storyboard in
			return controllersByID + storyboard.controllersbyID
		}

		for case let parentController as SceneController in Array(controllersByID.values) {
			for relationship in parentController.relationships {
				if case .viewControllers = relationship.kind {
					parentController.isRootController = true
					parentController.isContainerScoped = true
				}

				if let destination = controllersByID[relationship.destinationID] {
					destination.isContainerScoped = parentController.isContainerScoped
					relationship.resolve(toDestination: destination)
				}
			}
		}
	}

}
