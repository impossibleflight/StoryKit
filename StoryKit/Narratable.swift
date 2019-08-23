//
//  Narratable.swift
//  StoryKit
//
//  Created by John Clayton on 8/22/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

public protocol Narratable {
	// Appends scene to the current story (which is the receiver if the receiver is a story) and returns it
	@discardableResult func segue(toScene scene: SceneDescriptor?, transition: TransitionProtocol, source: SceneDescriptor?, unlessConditionMet condition: Condition?) -> Self
}

public extension Narratable {
	@discardableResult func root(_ scene: SceneDescriptor?, unlessConditionMet condition: Condition? = nil) -> Self {
		return segue(toScene: scene, transition: SystemTransition.root, source: nil, unlessConditionMet: condition)
	}

	@discardableResult func select(_ scene: SceneDescriptor?, unlessConditionMet condition: Condition? = nil) -> Self {
		return segue(toScene: scene, transition: SystemTransition.select, source: nil, unlessConditionMet: condition)
	}

	@discardableResult func set(_ scene: SceneDescriptor?, unlessConditionMet condition: Condition? = nil) -> Self {
		return segue(toScene: scene, transition: SystemTransition.set, source: nil, unlessConditionMet: condition)
	}

	@discardableResult func embed(_ scene: SceneDescriptor?, in containing: SceneDescriptor, unlessConditionMet condition: Condition? = nil) -> Self {
		return segue(toScene: scene, transition: SystemTransition.embed, source: containing, unlessConditionMet: condition)
	}

	@discardableResult func push(_ scene: SceneDescriptor?, unlessConditionMet condition: Condition? = nil) -> Self {
		return segue(toScene: scene, transition: SystemTransition.push, source: nil, unlessConditionMet: condition)
	}

	@discardableResult func pop(unlessConditionMet condition: Condition? = nil) -> Self {
		return segue(toScene: nil, transition: SystemTransition.pop, source: nil, unlessConditionMet: condition)
	}

	@discardableResult func pop(_ scene: SceneDescriptor?, unlessConditionMet condition: Condition? = nil) -> Self {
		return segue(toScene: scene, transition: SystemTransition.popTo, source: nil, unlessConditionMet: condition)
	}

	@discardableResult func popToRoot(unlessConditionMet condition: Condition? = nil) -> Self {
		return segue(toScene: nil, transition: SystemTransition.popToRoot, source: nil, unlessConditionMet: condition)
	}

	@discardableResult func present(_ scene: SceneDescriptor?, from presenting: SceneDescriptor? = nil, unlessConditionMet condition: Condition? = nil) -> Self {
		return segue(toScene: scene, transition: SystemTransition.present, source: presenting, unlessConditionMet: condition)
	}

	@discardableResult func dismiss(_ scene: SceneDescriptor?, unlessConditionMet condition: Condition? = nil) -> Self {
		return segue(toScene: scene, transition: SystemTransition.dismiss, source: nil, unlessConditionMet: condition)
	}

	@discardableResult func unwind(_ scene: SceneDescriptor?, unlessConditionMet condition: Condition? = nil) -> Self {
		return segue(toScene: scene, transition: SystemTransition.unwind, source: nil, unlessConditionMet: condition)
	}
}


