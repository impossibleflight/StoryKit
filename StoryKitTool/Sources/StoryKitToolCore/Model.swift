//
//  Model.swift
//  StoryKitTool
//
//  Created by John Clayton on 1/19/19.
//  Copyright © 2019 Impossible Flight, LLC. All rights reserved.
//

import Foundation

class Storyboard {
	var name: String
	init(name: String) {
		self.name = name
	}

	var initialViewControllerID: String?
	var initialViewController: SceneController? {
		return sceneControllers.filter({ $0.id == initialViewControllerID }).first
	}

	private(set) var controllers = [Controller]()
	func add(controller: Controller) {
		controllers.append(controller)
	}

	var sceneControllers: [SceneController] {
		return controllers.compactMap({ $0 as? SceneController })
	}
	
	var placeholders: [SceneControllerPlaceholder] {
		return controllers.compactMap({ $0 as? SceneControllerPlaceholder })
	}
}

extension Storyboard {
	func controller(withID id: String) -> Controller? {
		return sceneControllers.filter({ $0.id == id }).first
	}
	func sceneController(identifiedBy storyboardIdentifier: String) -> SceneController? {
		return sceneControllers.filter({ $0._storyboardIdentifier == storyboardIdentifier }).first
	}
	var controllersbyID: [String:Controller] {
		return controllers.reduce([String:Controller](), { controllersbyID, controller in
			return controllersbyID + [controller.id:controller]
		})
	}
}

class Relationship {
	enum Kind: String {
		case rootViewController
		case viewControllers
		case none = ""
	}
	var id: String
	var destinationID: String
	var kind: Kind
	private(set) var destinationController: Controller?

	init(id: String, destination: String, kind: String) {
		self.id = id
		self.destinationID = destination
		self.kind = Kind(rawValue: kind) ?? .none
	}

	func resolve(toDestination destination: Controller) {
		destinationController = destination
	}

	var resolved: Bool {
		return destinationController != nil
	}
}

protocol Controller: class, CustomStringConvertible {
	var id: String { get }
	var storyboardIdentifier: String? { get }
	var title: String? { get }
	var customClass: String? { get }
	var inputSignature: String? { get }
	var isContainerScoped: Bool { get set }
}

extension Controller {
	var inputLabel: String? {
		return inputMatches?.label
	}

	var inputTypeName: String? {
		return inputMatches?.typename
	}

	private var inputMatches: (label: String, typename: String)? {
		guard let inputSignature = inputSignature else {
			return nil
		}
		let pattern = "\\((\\w+):\\s*(\\w+)\\)"
		let regex = try! NSRegularExpression(pattern: pattern, options: [])
		if let match = regex.firstMatch(in: inputSignature, options: [], range: NSRange(in: inputSignature)) {
				let label = (inputSignature as NSString).substring(with: match.range(at: 1))
				let typename = (inputSignature as NSString).substring(with: match.range(at: 2))
				return (label: label, typename: typename)
		}
		return nil
	}
}

extension Controller {
	static func ==(lhs: Self, rhs: Self) -> Bool {
		return lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

class SceneController: Controller {
	var id: String
	private(set) var _storyboardIdentifier: String
	var storyboardIdentifier: String? { return _storyboardIdentifier }
	var title: String?
	var customClass: String?
	var inputSignature: String?
	private(set) var relationships: [Relationship] = []
	var isRootController: Bool = false
	var isContainerScoped: Bool = false

	init(id: String, storyboardIdentifier: String, title: String?, customClass: String?, inputSignature: String?) {
		self.id = id
		self._storyboardIdentifier = storyboardIdentifier
		self.title = title
		self.customClass = customClass
		self.inputSignature = inputSignature
	}

	func add(relationship: Relationship) {
		relationships.append(relationship)
	}

	func add(relationships: [Relationship]) {
		self.relationships.append(contentsOf: relationships)
	}
}

extension SceneController: Hashable {}

extension SceneController: CustomStringConvertible {
	var description: String {
		let address = Int(bitPattern: ObjectIdentifier(self))
		var description = String(format: "<%@ %0llx> identifier = '%@'", String(describing: SceneController.self), address, _storyboardIdentifier)
		if let title = title {
			description += ", title = '\(title)'"
		}
		if let customClass = customClass {
			description += ", customClass = '\(customClass)'"
		}
		if let inputSignature = inputSignature {
			description += ", inputSignature = '\(inputSignature)'"
		}
		return description
	}
}

class SceneControllerPlaceholder {
	var id: String
	var storyboardIdentifier: String?
	var storyboardName: String
	var referencedIdentifier: String?
	var isContainerScoped: Bool = false
	private(set) var referencedController: SceneController?

	init(id: String, storyboardIdentifier: String?, storyboardName: String, referencedIdentifier: String?) {
		self.id = id
		self.storyboardIdentifier = storyboardIdentifier
		self.storyboardName = storyboardName
		self.referencedIdentifier = referencedIdentifier
	}

	func resolve(toController controller: SceneController) {
		referencedController = controller
	}
	
	var resolved: Bool {
		return referencedController != nil
	}
}

extension SceneControllerPlaceholder: Controller {
	private var validatedReference: SceneController! {
		precondition(referencedController != nil, "referencedController is invalid!")
		return referencedController!
	}

	var title: String? {
		return validatedReference.title
	}

	var customClass: String? {
		return validatedReference.customClass
	}

	var inputSignature: String? {
		return validatedReference.inputSignature
	}
}

extension SceneControllerPlaceholder: CustomStringConvertible {
	var description: String {
		let address = Int(bitPattern: ObjectIdentifier(self))
		return String(format: "<%@ %0llx> identifier = '%@', storyboardName = '%@', referencedIdentifier = '%@', referencedController = '%@'", String(describing: SceneControllerPlaceholder.self), address, String(describing: storyboardIdentifier), storyboardName, String(describing: referencedIdentifier), String(describing: referencedController))
	}
}

class AnyController: Controller, Hashable {
	let value: Controller
	init(_ value: Controller) {
		self.value = value
	}

	var id: String { return value.id }
	var storyboardIdentifier: String? { return value.storyboardIdentifier }
	var title: String? { return value.title }
	var customClass: String? { return value.customClass }
	var inputSignature: String? { return value.inputSignature }
	var isContainerScoped: Bool {
		get { return value.isContainerScoped }
		set { value.isContainerScoped = newValue }
	}
}

extension AnyController: CustomStringConvertible {
	var description: String {
		let address = Int(bitPattern: ObjectIdentifier(self))
		return String(format: "<%@ %0llx> value = '%@'", String(describing: AnyController.self), address, String(describing: value))
	}
}
