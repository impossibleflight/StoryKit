//
//  StoryboardBuilder.swift
//  StoryKitTool
//
//  Created by John Clayton on 1/19/19.
//  Copyright © 2019 Impossible Flight, LLC. All rights reserved.
//

import Foundation

class StoryboardBuilder {
	enum Error: Swift.Error, CustomStringConvertible {
		case missingID(url: URL, element: XMLElement)
		case missingStoryboardIdentifier(url: URL, element: XMLElement)
		case restorationIdentifierMismatch(url: URL, element: XMLElement)
		case missingStoryboardName(url: URL, element: XMLElement)
		case missingReferencedIdentifier(url: URL, element: XMLElement)

		var description: String {
			switch self {
			case let .missingID(url, element):
				return "Missing id attribute! \(url) \(element)"
			case let .missingStoryboardIdentifier(url, element):
				return "StoryKit requires all view controllers loaded from storyboards to have identifiers. \(url) \(element)"
			case let .restorationIdentifierMismatch(url, element):
				return "StoryKit requires all view controllers to have the same storyboard and restoration identifiers. Make sure they are the same or check 'Use Storyboard ID' for the restoration identifier. \(url) \(element)"
			case let .missingStoryboardName(url, element):
				return "Storyboard references must have storyboard names. \(url) \(element)"
			case let .missingReferencedIdentifier(url, element):
				return "Storyboard references must have referenced identifiers. \(url) \(element)"
			}
		}
	}

	private var url: URL!
	func build(name: String, fromURL url: URL) throws -> Storyboard {
		self.url = url
		let storyboard = Storyboard(name: name)
		let xml = try XMLDocument(contentsOf: url, options: [])
		let documentElement = xml.rootElement()
		let initialViewControllerID = documentElement?.attribute(forName: "initialViewController")?.stringValue
		storyboard.initialViewControllerID = initialViewControllerID
		let controllerElements = try xml.nodes(forXPath: "/document/scenes/scene/objects/*[@sceneMemberID='viewController']")
		for case let controllerElement as XMLElement in controllerElements {
			let controller = try buildController(withElement: controllerElement)
			storyboard.add(controller: controller)
		}
		return storyboard
	}

	private func buildController(withElement controllerElement: XMLElement) throws -> Controller {
		let name = controllerElement.name

		let isPlaceholder = (name == "viewControllerPlaceholder")
		guard !isPlaceholder else {
			return try buildControllerPlaceholder(withElement: controllerElement)
		}
		guard let id = controllerElement.attribute(forName: "id")?.stringValue else {
			throw Error.missingID(url: url, element: controllerElement)
		}
		guard let storyboardIdentifier = controllerElement.attribute(forName: "storyboardIdentifier")?.stringValue else {
			throw Error.missingStoryboardIdentifier(url: url, element: controllerElement)
		}

		// Validate restoration identifier
		let restorationIdentifier: String
		let useStoryboardIdentifierAsRestorationIdentifierString = controllerElement.attribute(forName: "useStoryboardIdentifierAsRestorationIdentifier")?.stringValue ?? "false"
		let useStoryboardIdentifierAsRestorationIdentifier = (useStoryboardIdentifierAsRestorationIdentifierString as NSString).boolValue

		if useStoryboardIdentifierAsRestorationIdentifier {
			restorationIdentifier = storyboardIdentifier
		} else {
			restorationIdentifier = controllerElement.attribute(forName: "restorationIdentifier")?.stringValue ?? ""
		}

		guard storyboardIdentifier == restorationIdentifier else {
			throw Error.restorationIdentifierMismatch(url: url, element: controllerElement)
		}

		let title = controllerElement.attribute(forName: "title")?.stringValue
		let customClass = controllerElement.attribute(forName: "customClass")?.stringValue

		var inputSignature: String? = nil
		if let inputSignatureRuntimeAttributeElement = try controllerElement.nodes(forXPath: "./userDefinedRuntimeAttributes/userDefinedRuntimeAttribute[@keyPath='inputSignature']").first as? XMLElement {
			inputSignature = inputSignatureRuntimeAttributeElement.attribute(forName: "value")?.stringValue
		}

		let controller = SceneController(id: id, storyboardIdentifier: storyboardIdentifier, title: title, customClass: customClass, inputSignature: inputSignature)
		controller.add(relationships: try buildRelationships(withElement: controllerElement))
		return controller
	}

	private func buildControllerPlaceholder(withElement placeholderElement: XMLElement) throws -> SceneControllerPlaceholder {
		guard let id = placeholderElement.attribute(forName: "id")?.stringValue else {
			throw Error.missingID(url: url, element: placeholderElement)
		}
		guard let storyboardName = placeholderElement.attribute(forName: "storyboardName")?.stringValue else {
			throw Error.missingStoryboardName(url: url, element: placeholderElement)
		}
		let referencedIdentifier = placeholderElement.attribute(forName: "referencedIdentifier")?.stringValue
		let storyboardIdentifier = placeholderElement.attribute(forName: "storyboardIdentifier")?.stringValue

		return SceneControllerPlaceholder(id: id, storyboardIdentifier: storyboardIdentifier, storyboardName: storyboardName, referencedIdentifier: referencedIdentifier)
	}

	private func buildRelationships(withElement controllerElement: XMLElement) throws -> [Relationship] {
		var relationships = [Relationship]()
		let relationshipSegues = try controllerElement.nodes(forXPath: "./connections/segue[@kind='relationship']")
		for case let relationshipSegue as XMLElement in relationshipSegues {
			if let id = relationshipSegue.attribute(forName: "id")?.stringValue
				, let destination = relationshipSegue.attribute(forName: "destination")?.stringValue
				, let kind = relationshipSegue.attribute(forName: "relationship")?.stringValue {
				let relationship = Relationship(id: id, destination: destination, kind: kind)
				relationships.append(relationship)
			}
		}
		return relationships
	}


}
