//
//  Storyboard.swift
//  StoryKit
//
//  Created by John Clayton on 8/22/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit
import Bridge

public enum Scope {
	case transient
	case container
}

extension SceneDescriptor {
	var scopeKey: SceneIdentifier {
		return self.identifier
	}
	var storyboardIdentifier: String {
		return self.name
	}
}

public class Storyboard<S: SceneDescriptor>  {
	enum Error: Swift.Error, CustomStringConvertible {
		case usedSnapshotAsDescriptor(SceneDescriptor)
		case underlyingStoryboardError(Storyboard, UIStoryboard.Error)

		var description: String {
			switch self {
			case .usedSnapshotAsDescriptor(let descriptor):
				let controller = try? descriptor.sceneController()
				return "Could not infer a descriptor for controller in storyboard: \(String(describing: controller)). Did you forget to register the storyboard descriptor with StoryKit, add a case for the referenced controller, or add its restoration identifier to the descriptor?"
			case .underlyingStoryboardError(let storyboard, let underlyingError):
				return "\(storyboard) -> \(underlyingError)"
			}
		}
	}

	var descriptorType: S.Type
	var bundle: Bundle?

	public static func described<T: SceneDescriptor>(by descriptor: T, bundle: Bundle? = nil) throws -> Storyboard<T> {
		guard !(descriptor is _InternalDescriptor) else {
			throw Error.usedSnapshotAsDescriptor(descriptor)
		}
		let cacheKey = descriptor.typeIdentifier
		if let s = storyboardCache[cacheKey] as? Storyboard<T> {
			return s
		}
		let s = try Storyboard<T>(descriptorType: T.self)
		storyboardCache[cacheKey] = s
		return s
	}

	private init(descriptorType: S.Type, bundle: Bundle? = nil) throws {
		self.descriptorType = S.self
		self.bundle = bundle
		let name = String(describing: descriptorType)
		_storyboard = try ObjC.throwingReturn { UIStoryboard(name: name, bundle: bundle) }
	}

	public func viewController<V: UIViewController>(forScene descriptor: S, scope: Scope = .transient, initializer: ((V) -> Void)? = nil) throws -> V {
		if scope == .container, let controller = containerScope[descriptor.scopeKey] as? V {
			return controller
		}

		let controller: V
		do {
			controller = try _storyboard.instantiateViewController(withIdentifier: descriptor.storyboardIdentifier)
		} catch let error as UIStoryboard.Error {
			throw Error.underlyingStoryboardError(self, error)
		}

		controller.freeze(descriptor: descriptor)
		if scope == .container {
			containerScope[descriptor.scopeKey] = controller
			try addChildrenInContainerScope(node: controller)
		}
		if let initializer = initializer {
			initializer(controller)
		}

		return controller
	}

	public func register<V: UIViewController>(viewController: V, forScene descriptor: S) throws {
		viewController.freeze(descriptor: descriptor)
		containerScope[descriptor.scopeKey] = viewController
		try addChildrenInContainerScope(node: viewController)
	}

//MARK: Private

	private func addChildrenInContainerScope(node: UIViewController) throws {
		for child in node.children {
			let childDescriptor = child.sceneDescriptor
			let bundle: Bundle = Bundle(for: type(of: child))
			try childDescriptor.registerInBoard(viewController: child, bundle: bundle)
		}
	}

	fileprivate var containerScope = Dictionary<String,UIViewController>()
	fileprivate var _storyboard: UIStoryboard
}

fileprivate var storyboardCache = Dictionary<String,Any>()

extension SceneDescriptor {
	// This inversion (over just creating the storyboard using the value of controller.sceneDescriptor) is necessary because we cannot get the concrete type of controller.sceneDescriptor statically (as it is a constrained to a protocol at runtime), and so cannot create a storyboard constrained to that type. Using Self here opens the existential and the compiler can replace with the current concrete type.
	func registerInBoard<V: UIViewController>(viewController: V, bundle: Bundle? = nil) throws {
		let board = try Storyboard<Self>.described(by: self)
		try board.register(viewController: viewController, forScene: self)
	}
}

extension FrozenDescriptor {
	func registerInBoard<V: UIViewController>(viewController: V, bundle: Bundle? = nil) throws {
		let board = try Storyboard<DescriptorType>.described(by: self.descriptor)
		try board.register(viewController: viewController, forScene: self.descriptor)
	}
}

extension Storyboard: CustomStringConvertible {
	public var description: String {
		return "Storyboard<\(descriptorType)>"
	}
}
