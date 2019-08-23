//
//  UIViewController+StoryKit.swift
//  StoryKit
//
//  Created by John Clayton on 9/19/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit
import Bridge

fileprivate extension NSObjectProtocol {
	var moduleName: String? {
		let nameComponents = NSStringFromClass(type(of: self)).split(separator: ".")
		guard nameComponents.count > 1 else {
			return nil
		}
		return String(nameComponents.first!)
	}
}

public protocol SceneController {
	var sceneDescriptor: SceneDescriptor { get }
//	func getSceneDescriptor<S: SceneDescriptor>() -> S
//	func setSceneDescriptor<S: SceneDescriptor>(_ descriptor: S)
}

extension UIViewController: SceneController {

	fileprivate struct AssociationKeys {
		static var frozenDescriptor = "frozenDescriptor"
	}

	/// A descriptor that is frozen in time to return only the receiver as the view controller
//	private var frozenDescriptor: SceneDescriptor? {
//		get {
//			if let frozenDescriptor: FrozenDescriptor = get(associatedObjectForKey: &AssociationKeys.frozenDescriptor) {
//				return frozenDescriptor
//			}
//			return nil
//		}
//		set {
//			var frozenDescriptor: FrozenDescriptor? = nil
//			if let descriptor = newValue {
//				frozenDescriptor = FrozenDescriptor(descriptor, sceneController: self)
//			}
//			set(associatedObject: frozenDescriptor, forKey: &AssociationKeys.frozenDescriptor)
//		}
//	}

	func freeze<S: SceneDescriptor>(descriptor: S) {
		let frozenDescriptor = FrozenDescriptor(descriptor, sceneController: self)
		objc_setAssociatedObject(self as Any, &AssociationKeys.frozenDescriptor, (frozenDescriptor as SceneDescriptor), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
	}

	func getFrozenDescriptor() -> SceneDescriptor? {
		if let frozenDescriptor = objc_getAssociatedObject(self, &AssociationKeys.frozenDescriptor) {
			// There is a bug in swift that won't allow casting from Any to a protocol directly if the underlying type is a struct.
			// Cast to AnyObject first to work around this
			// https://bugs.swift.org/browse/SR-3871
			let asObject = frozenDescriptor as AnyObject
			let descriptor = asObject as? SceneDescriptor
			return descriptor
		}
		return nil
	}

	private var inferredSceneDescriptor: SceneDescriptor? {
		guard let storyboardName = self.storyboardName, let restorationIdentifier = self.restorationIdentifier else {
			return nil
		}
		guard let descriptor = StoryKit.descriptor(forName: storyboardName, identifier: restorationIdentifier) else {
			return nil
		}
//		// Once we have inferred a descriptor we need to freeze it so it returns us as the view controller
//		frozenDescriptor = descriptor
//		return frozenDescriptor
		return descriptor
	}

//	private func inferDescriptor<S: SceneDescriptor>() -> S? {
//		guard let storyboardName = self.storyboardName, let restorationIdentifier = self.restorationIdentifier else {
//			return nil
//		}
//		if let inferredDescriptor: S = StoryKit.descriptor(forName: storyboardName, identifier: restorationIdentifier) {
//			// Once we have inferred a descriptor we need to freeze it so it returns us as the view controller
//			freeze(descriptor: inferredDescriptor)
//			if let frozenDescriptor =  getFrozenDescriptor() {
//				return frozenDescriptor as? S
//			}
//		}
//		return nil
//	}

	public var sceneDescriptor: SceneDescriptor {
		get {
			if let descriptor = getFrozenDescriptor()  {
				return descriptor
			}
			if let descriptor: SceneDescriptor = inferredSceneDescriptor {
				return descriptor
			}
			if assertViewControllerNotSceneController {
				let currentModule = UIApplication.shared.delegate?.moduleName
				if moduleName == currentModule {
					assertionFailure("Application module view controller \(self) did not have a scene descriptor!")
				}
			}
			return staticDescriptor
		}
	}

//	public func getSceneDescriptor<S: SceneDescriptor>() -> S {
//		if let descriptor = getFrozenDescriptor() as? S {
//			return descriptor
//		}
//		if let descriptor: S = inferDescriptor() {
//			return descriptor
//		}
//		if assertViewControllerNotSceneController {
//			let currentModule = UIApplication.shared.delegate?.moduleName
//			if moduleName == currentModule {
//				assertionFailure("Application module view controller \(self) did not have a scene descriptor!")
//			}
//		}
//		return staticDescriptor as! S
//	}
//
//	public func setSceneDescriptor<S: SceneDescriptor>(_ descriptor: S) {
//		freeze(descriptor: descriptor)
//	}


	var staticDescriptor: StaticDescriptor {
		return StaticDescriptor(sceneController: self)
	}
}

