//
//  SceneDescriptor.swift
//  StoryKit
//
//  Created by John Clayton on 11/26/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

public typealias TypeIdentifier = String
public typealias SceneIdentifier = String

public protocol _SceneDescriptor {
	var typeIdentifier: TypeIdentifier { get }
	var name: String { get }
	var identifier: SceneIdentifier { get }
	func isEqual(to: _SceneDescriptor) -> Bool
}

public protocol SceneDescriptor: _SceneDescriptor {
	func sceneController() throws -> UIViewController
}

public protocol SceneDescriptorConstructing {
	static func by(restorationIdentifier: String) -> SceneDescriptor?
}

public protocol StoryboardSceneDescriptor: SceneDescriptor, SceneDescriptorConstructing {
	static var restorationIdentifiers: [Self] { get }
}

public protocol SceneControllerInitializing {
	func didLoad<V: UIViewController>(sceneController: V)
}

public extension _SceneDescriptor {
	var typeIdentifier: TypeIdentifier {
		return "\(String(describing: Self.self))"
	}
	var name: String {
		let mirror = Mirror(reflecting: self)
		if let label = mirror.children.first?.label {
			return label
		} else {
			return String(describing:self)
		}
	}
	var identifier:  SceneIdentifier {
		return "\(Self.self).\(String(describing: self))"
	}
	func isEqual(to other: _SceneDescriptor) -> Bool {
		return self.identifier == other.identifier
	}
}

func ==(lhs: _SceneDescriptor, rhs: _SceneDescriptor) -> Bool {
	return lhs.isEqual(to: rhs)
}

public extension SceneDescriptor {
	/// Provides a default method for loading a view controller for the receiver from a storyboard matching the receiver's type. If the scope is `.container` then the returned view controller may have been cached after being initialized by the storyboard.
	///
	/// - Parameters:
	///   - scope: <#scope description#>
	///   - initializer: <#initializer description#>
	/// - Throws: <#throws value description#>
	func sceneControllerFromStoryboard<V: UIViewController>(inScope scope: Scope = .transient, initializer: ((V) -> Void)? = nil) throws -> V {
		let board = try Storyboard<Self>.described(by: self)
		let controller: V =  try board.viewController(forScene: self, scope: scope, initializer: initializer)
		return controller
	}

	/// Calls `viewController()` and returns nil if that function throws an exception. Fires an assertion in -Onone builds if an exception is trapped.
	var sceneController: UIViewController? {
		do {
			return try sceneController()
		} catch {
			assertionFailure("Failed to load view controller for descriptor \(self)")
			return nil
		}
	}
}

public extension StoryboardSceneDescriptor  {
	static func by(restorationIdentifier: String) -> SceneDescriptor? {
		for r in Self.restorationIdentifiers {
			if "\(r.name)" == restorationIdentifier {
				return r
			}
		}
		return nil
	}
}

protocol _InternalDescriptor {}

struct FrozenDescriptor<DescriptorType: SceneDescriptor> : SceneDescriptor, _InternalDescriptor {
	public init(_ descriptor: DescriptorType, sceneController: UIViewController) {
		self.descriptor = descriptor
		_sceneController = sceneController
	}

	public func describedType<T: SceneDescriptor>() -> T.Type {
		return DescriptorType.self as! T.Type
	}
	public var typeIdentifier: String { return descriptor.typeIdentifier }

	public var name: String { return descriptor.name }
	public var identifier: SceneIdentifier { return descriptor.identifier }
	public func sceneController() throws -> UIViewController { return _sceneController }
	public func isEqual(to other: SceneDescriptor) -> Bool { return descriptor.isEqual(to: other) }

	private(set) public var descriptor: DescriptorType
	private weak var _sceneController: UIViewController!
}

struct InverseDescriptor: SceneDescriptor {
	init(factory: @escaping () throws -> UIViewController) {
		self.factory = factory
	}

	var identifier: String {
		return "../"
	}

	private var factory: () throws -> UIViewController
	func sceneController() throws -> UIViewController {
		return try factory()
	}
}

/// A descriptor that can be built as a last resort from a scene controller that does not provide a descriptor using an identifier that represents that instance of the scene controller
struct StaticDescriptor: SceneDescriptor, _InternalDescriptor {
	init(sceneController: UIViewController) {
		self._sceneController = sceneController
	}

	public var identifier: String {
		return _sceneController.staticIdentifier
	}

	private var _sceneController: UIViewController
	public func sceneController() throws -> UIViewController {
		return _sceneController
	}
}
