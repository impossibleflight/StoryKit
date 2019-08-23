//
//  Scene.swift
//  StoryKit
//
//  Created by John Clayton on 8/22/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

protocol PathRepresentable {
	var segmentRepresentation: String { get }
}

protocol SceneProtocol: class, Scriptable, PathRepresentable, CustomStringConvertible {
	var source: SceneDescriptor? { get }
	var destination: SceneDescriptor? { get }
	var transition: TransitionProtocol { get }
	var condition: Condition? { get }
	var junctionWith: SceneProtocol? { get set }
	var isJunction: Bool { get }
	var isRoot: Bool { get }
	var name: String { get }
	func sourceSceneController() throws -> UIViewController?
	func destinationSceneController() throws -> UIViewController?
	func inverse() throws -> SceneProtocol
}

//MARK: Scriptable

extension SceneProtocol {
	func matches(string: String) -> Bool {
		return segmentRepresentation.caseInsensitiveCompare(string) == .orderedSame
	}
}

//MARK: PathRepresentable

extension SceneProtocol {
	var segmentRepresentation: String {
		return isRoot ? "/" : name
	}
}

extension SceneProtocol {
	var isJunction: Bool {
		return junctionWith != nil
	}

	var isRoot: Bool {
		return transition.isRoot
	}

	var name: String {
		return destination?.name ?? "???"
	}

	func sourceSceneController() throws -> UIViewController? {
		return try source?.sceneController()
	}

	func inverse() throws -> SceneProtocol {
		var descriptor: SceneDescriptor?
		if let destination = destination {
			let factory = { 
				return try destination.sceneController()
			}
			descriptor = InverseDescriptor(factory: factory)
		}
		return Scene(descriptor: descriptor, transition: transition.inverse)
	}
}

extension SceneProtocol {
	/// Equality for scenes really is universal across all implmentations: as far as the stage is concerned we have the same scene if it has the same descriptor (type and identifier) and transition (conversely, it is an error to represent different scenes with the same scene descriptor).
	func isEqual(_ other: SceneProtocol) -> Bool {
		var destinationsEqual = false
		switch (self.destination, other.destination) {
		case let (.some(left), .some(right)):
			destinationsEqual = left == right
		case (.none, .none):
			destinationsEqual = true
		case (.some(_), .none), (.none, .some(_)):
			destinationsEqual = false
		}
		return destinationsEqual && self.transition == other.transition
	}
}

extension SceneProtocol {
	var description: String {
		let address = Int(bitPattern: ObjectIdentifier(self))
		return String(format: "<%@ %0llx> name = %@, transition = %@", String(describing: Self.self), address, name, String(describing: transition))
	}
	var shorthand: String {
		return "\(transition.operator)(\(name))"
	}
}

class Scene: SceneProtocol {
	private(set) var source: SceneDescriptor?
	private(set) var destination: SceneDescriptor?
	private(set) var transition: TransitionProtocol
	private(set) var condition: Condition?
	var junctionWith: SceneProtocol?

	init(descriptor: SceneDescriptor?, transition: TransitionProtocol, source: SceneDescriptor? = nil, condition: Condition? = nil) {
		self.source = source
		self.destination = descriptor
		self.transition = transition
		self.condition = condition
	}

	func destinationSceneController() throws -> UIViewController? {
		if let viewController = _viewController  {
			return viewController
		}
		let controller = try destination?.sceneController()
		_viewController = controller
		return controller
	}

	private var _viewController: UIViewController?
}

class InputScene<Input> : SceneProtocol {
	private(set) var source: SceneDescriptor?
	private(set) var destination: SceneDescriptor?
	private(set) var transition: TransitionProtocol
	private(set) var condition: Condition?
	var junctionWith: SceneProtocol?
	var name: String {
		return String(describing: input)
	}

	private(set) var input: Input

	init(descriptor: SceneDescriptor, factory: @escaping (Input) -> SceneDescriptor, input: Input, transition: TransitionProtocol, source: SceneDescriptor? = nil, condition: Condition? = nil) {
		self.source = source
		self.destination = descriptor
		self.factory = factory
		self.input = input
		self.transition = transition
		self.condition = condition
	}

	func destinationSceneController() throws -> UIViewController? {
		if let viewController = _viewController  {
			return viewController
		}
		let descriptor: SceneDescriptor = factory(input)
		let controller = try descriptor.sceneController()
		_viewController = controller
		return controller
	}

	private var factory: (Input) -> SceneDescriptor
	private var _viewController: UIViewController?
}

class StaticScene: SceneProtocol {
	let source: SceneDescriptor? = nil
	private(set) var destination: SceneDescriptor?
	private(set) var transition: TransitionProtocol
	let condition: Condition? = nil
	var junctionWith: SceneProtocol?

	init(descriptor: SceneDescriptor, viewController: UIViewController, transition: TransitionProtocol) {
		self.destination = descriptor
		_viewController = viewController
		self.transition = transition
	}

	func destinationSceneController() throws -> UIViewController? {
		return _viewController
	}

	private var _viewController: UIViewController
}

//MARK: A concrete type erased box so we can get Equatable behavior for all SceneTypes

extension SceneProtocol {
	func asAnyScene() -> AnyScene {
		return AnyScene(self)
	}
}

public class AnyScene: SceneProtocol {
	private(set) var value: SceneProtocol

	init<TransitionType: SceneProtocol>(_ value: TransitionType) {
		self.value = value
	}

	var source: SceneDescriptor? {
		return value.source
	}

	var destination: SceneDescriptor? {
		return value.destination
	}
	var transition: TransitionProtocol {
		return value.transition
	}

	var condition: Condition? {
		return value.condition
	}

	var junctionWith: SceneProtocol? {
		get {
			return value.junctionWith
		}
		set {
			value.junctionWith = newValue
		}
	}

	var name: String {
		return value.name
	}

	func sourceSceneController() throws -> UIViewController? {
		return try value.sourceSceneController()
	}

	func destinationSceneController() throws -> UIViewController? {
		return try value.destinationSceneController()
	}
}

extension AnyScene: Equatable {
	// Uses the protocol's definition of equality
	public static func==(lhs: AnyScene, rhs: AnyScene) -> Bool {
		return lhs.isEqual(rhs)
	}
}

extension AnyScene: CustomStringConvertible {
	public var description: String {
		let address = Int(bitPattern: ObjectIdentifier(self))
		return String(format: "<%@ %0llx> value = %@,", String(describing: AnyScene.self), address, String(describing: value))
	}
}

extension AnyScene: PathRepresentable {
	var segmentRepresentation: String {
		return value.segmentRepresentation
	}
}

extension AnyScene: Scriptable {
	func matches(string: String) -> Bool {
		return value.matches(string: string)
	}
}
