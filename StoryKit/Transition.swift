//
//  Transition.swift
//  StoryKit
//
//  Created by John Clayton on 8/22/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit
import Bridge

public struct Transition {
	public enum Direction {
		case forward
		case backward
	}

	public typealias Worker = (_ stage: Stage, _ actor: SceneActing, _ source: UIViewController?, _ destination: UIViewController?, _ animated: Bool, _ completion: Completion?) -> Void
	public typealias Completion = (_ complete: Bool) -> Void
}

public protocol TransitionProtocol {
	var identifier: String { get }
	var direction: Transition.Direction { get }
	var inverse: TransitionProtocol { get }
	var isJunction: Bool { get }
	var isRoot: Bool { get }
	var `operator`: String { get }
	var worker: Transition.Worker { get }
}

extension TransitionProtocol {
	var identifier: String {
		let mirror = Mirror(reflecting: self)
		if let label = mirror.children.first?.label {
			return label
		} else {
			return String(describing:self)
		}
	}
}

// We enforce equality at the protocol level because it is a requirement of the system that any transition equals another if the identifier and type are the same. We don't adopt Equatable here because we don't need it and it creates issues with no longer being abe to use it as a type.
func==(lhs: TransitionProtocol, rhs: TransitionProtocol) -> Bool {
	return lhs.identifier == rhs.identifier
		&& type(of: lhs) == type(of: rhs)
}


//MARK: Default transitions

enum SystemTransition {
	case none
	case root
	case select
	case set
	case embed
	case push
	case pop
	case popTo
	case popToRoot
	case present
	case dismiss
	case dismissFrom
	case unwind
}

extension SystemTransition: TransitionProtocol {
	public var inverse: TransitionProtocol {
		var inverse = SystemTransition.none
		switch self {
		case .push:
			inverse = .pop
		case .pop:
			inverse = .push
		case .present:
			inverse = .dismiss
		case .dismiss:
			inverse = .present
		default:
			inverse = .none

		}
		return inverse
	}

	public var direction: Transition.Direction {
		var direction = Transition.Direction.forward
		switch self {
		case .none, .pop, .popTo, .popToRoot, .dismiss, .unwind:
			direction = .backward
		default:
			direction = .forward

		}
		return direction
	}

	public var isJunction: Bool {
		switch self {
		case .select, .embed:
			return true
		default:
			return false
		}
	}

	public var `operator`: String {
		switch self {
		case .none:
			return "∅"
		case .root:
			return "/"
		case .select:
			return "⫤"
		case .set:
			return "|"
		case .embed:
			return "▣"
		case .push:
			return ">"
		case .pop:
			return "<"
		case .popTo:
			return ".<"
		case .popToRoot:
			return "|<"
		case .present:
			return "^"
		case .dismiss:
			return "˅"
		case .dismissFrom:
			return "⩒"
		case .unwind:
			return "<~"
		}
	}

	public var isRoot: Bool {
		if self == .root { return true }
		return false
	}

	var worker: Transition.Worker {
		var worker: Transition.Worker
		switch self {
		case .none:
			worker = { stage, actor, source, destination, animated, completion in
				actor.destination = source
				completion?(true)
			}
		case .root: return root
		case .select: return select
		case .set: return set
		case .embed: return embed
		case .push: return push
		case .pop: return pop
		case .popTo: return popTo
		case .popToRoot: return popToRoot
		case .present: return present
		case .dismiss: return dismiss
		case .dismissFrom: return dismissFrom
		case .unwind: return unwind
		}
		return worker
	}
}

extension SystemTransition {
	private func root(stage: Stage, actor: SceneActing, source: UIViewController?, destination: UIViewController?, animated: Bool,  completion: Transition.Completion?) -> Void {
		guard let destination = destination else {
			assertionFailureOrPrint("Failed to get destination view controller for \(SystemTransition.root)")
			completion?(false)
			return
		}
		if let window = source?.view.window {
			window.rootViewController = destination
			completion?(true)
		} else {
			completion?(false)
		}
	}

	private func select(stage: Stage, actor: SceneActing, source: UIViewController?, destination: UIViewController?, animated: Bool,  completion: Transition.Completion?) -> Void {
		guard let source = source else {
			assertionFailureOrPrint("Failed to get source view controller for \(SystemTransition.select)")
			completion?(false)
			return
		}

		var tabs = source as? UITabBarController
		if tabs == nil {
			tabs = source.tabBarController
		}
		guard tabs != nil else {
			assertionFailureOrPrint("Failed to get tab bar controller from source view controller \(source) for \(SystemTransition.select)")
			completion?(false)
			return
		}
		tabs!.selectedViewController = destination
		completion?(true)
	}

	private func set(stage: Stage, actor: SceneActing, source: UIViewController?, destination: UIViewController?, animated: Bool,  completion: Transition.Completion?) -> Void {
		guard let source = source else {
			assertionFailureOrPrint("Failed to get source view controller for \(SystemTransition.set)")
			completion?(false)
			return
		}
		guard let destination = destination else {
			assertionFailureOrPrint("Failed to get destination view controller for \(SystemTransition.set)")
			completion?(false)
			return
		}


		var nav = source as? UINavigationController
		if nav == nil {
			nav = source.navigationController
		}

		guard nav != nil else {
			assertionFailureOrPrint("Failed to get nav controller from source view controller \(source) for \(SystemTransition.set)")
			completion?(false)
			return
		}

		nav!.setViewControllers([destination], animated: animated)
		completion?(true)
	}

	private func embed(stage: Stage, actor: SceneActing, source: UIViewController?, destination: UIViewController?, animated: Bool,  completion: Transition.Completion?) -> Void {
		guard let source = source as? ContainingController&UIViewController else {
			assertionFailureOrPrint("Failed to get source view controller as a \(ContainingController.self) for \(SystemTransition.embed)")
			completion?(false)
			return
		}
		guard let destination = destination else {
			assertionFailureOrPrint("Failed to get destination view controller for \(SystemTransition.embed)")
			completion?(false)
			return
		}
		guard let containerView = source.containerView else {
			assertionFailureOrPrint("Failed to get containerView for \(SystemTransition.embed)")
			completion?(false)
			return
		}
		guard let destinationView = destination.view else {
			assertionFailureOrPrint("Failed to get destinationView for \(SystemTransition.embed)")
			completion?(false)
			return

		}

		destinationView.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview(destinationView)
		destinationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
		destinationView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
		destinationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
		destinationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true

		source.addChild(destination)
		destination.didMove(toParent: source)

		completion?(true)
	}

	private func push(stage: Stage, actor: SceneActing, source: UIViewController?, destination: UIViewController?, animated: Bool,  completion: Transition.Completion?) -> Void {
		guard let source = source else {
			assertionFailureOrPrint("Failed to get source view controller for \(SystemTransition.push)")
			completion?(false)
			return
		}
		guard let destination = destination else {
			assertionFailureOrPrint("Failed to get destination view controller for \(SystemTransition.push)")
			completion?(false)
			return
		}

		var nav = source.navigationController
		var origin = source
		while nav == nil, let presenting = origin.presentingViewController {
			nav = presenting.navigationController
			origin = presenting
		}

		guard nav != nil else {
			assertionFailureOrPrint("Failed to get nav controller from source view controller \(source) for \(SystemTransition.push)")
			completion?(false)
			return
		}

		CATransaction.begin()
		CATransaction.setCompletionBlock({
			completion?(true)
		})
		nav!.pushViewController(destination, animated: animated)
		CATransaction.commit()
	}

	private func _pop(stage: Stage, actor: SceneActing, source: UIViewController?, destination: UIViewController?, animated: Bool, toRoot: Bool = false, completion: Transition.Completion?) -> Void {
		let transition = toRoot ? SystemTransition.popToRoot: SystemTransition.pop

		guard let source = source else {
			assertionFailureOrPrint("Failed to get source view controller for \(transition)")
			completion?(false)
			return
		}
		guard let nav = source.navigationController else {
			assertionFailureOrPrint("Failed to get nav controller from source view controller \(source) for \(transition)")
			completion?(false)
			return
		}
		CATransaction.begin()
		CATransaction.setCompletionBlock({
			completion?(true)
		})
		if toRoot {
			_ = nav.popToRootViewController(animated: animated)
		} else {
			_ = nav.popViewController(animated: animated)
		}
		actor.destination = nav.topViewController
		CATransaction.commit()
	}

	private func pop(stage: Stage, actor: SceneActing, source: UIViewController?, destination: UIViewController?, animated: Bool,  completion: Transition.Completion?) -> Void {
		_pop(stage: stage, actor: actor, source: source, destination: destination, animated: animated, completion: completion)
	}

	private func popTo(stage: Stage, actor: SceneActing, source: UIViewController?, destination: UIViewController?, animated: Bool,  completion: Transition.Completion?) -> Void {
		guard let source = source else {
			assertionFailureOrPrint("Failed to get source view controller for \(SystemTransition.popTo)")
			completion?(false)
			return
		}
		guard let destination = destination else {
			assertionFailureOrPrint("Failed to get destination view controller for \(SystemTransition.popTo)")
			completion?(false)
			return
		}
		guard let nav = source.navigationController else {
			assertionFailureOrPrint("Failed to get nav controller from source view controller \(source) for \(SystemTransition.popTo)")
			completion?(false)
			return
		}
		CATransaction.begin()
		CATransaction.setCompletionBlock({
			completion?(true)
		})
		do {
			_ = try ObjC.throwingReturn  { nav.popToViewController(destination, animated: animated) }
		} catch {
			assertionFailureOrPrint("Trapped exception for \(SystemTransition.popTo) \(destination) \(error)")
		}
		actor.destination = destination
		CATransaction.commit()
	}

	private func popToRoot(stage: Stage, actor: SceneActing, source: UIViewController?, destination: UIViewController?, animated: Bool,  completion: Transition.Completion?) -> Void {
		_pop(stage: stage, actor: actor, source: source, destination: destination, animated: animated, toRoot: true, completion: completion)
	}

	private func present(stage: Stage, actor: SceneActing, source: UIViewController?, destination: UIViewController?, animated: Bool,  completion: Transition.Completion?) -> Void {
		guard let source = source else {
			assertionFailureOrPrint("Failed to get source view controller for \(SystemTransition.present)")
			completion?(false)
			return
		}
		guard let destination = destination else {
			assertionFailureOrPrint("Failed to get destination view controller for \(SystemTransition.present)")
			completion?(false)
			return
		}

		source.present(destination, animated: animated, completion: {
			completion?(true)
		})
	}

	private func _dismiss(stage: Stage, actor: SceneActing, from controller: UIViewController, animated: Bool,  completion: Transition.Completion?) -> Void {
		var result: UIViewController? = nil
		if let _ = controller.presentedViewController {
			result = controller
		} else if let presenting = controller.presentingViewController {
			result = presenting
		}

		guard result != nil else {
			assertionFailureOrPrint("No presentations to use with \(SystemTransition.dismiss)")
			completion?(false)
			return
		}

		controller.dismiss(animated: animated, completion: {
			completion?(true)
		})
		actor.destination = result
	}

	private func dismiss(stage: Stage, actor: SceneActing, source: UIViewController?, destination: UIViewController?, animated: Bool,  completion: Transition.Completion?) -> Void {
		guard let source = source else {
			assertionFailureOrPrint("Failed to get source view controller for \(SystemTransition.dismiss)")
			completion?(false)
			return
		}
		_dismiss(stage: stage, actor: actor, from: source, animated: animated, completion: completion)
	}

	private func dismissFrom(stage: Stage, actor: SceneActing, source: UIViewController?, destination: UIViewController?, animated: Bool,  completion: Transition.Completion?) -> Void {
		guard let destination = destination else {
			assertionFailureOrPrint("Failed to get destination view controller for \(SystemTransition.dismissFrom)")
			completion?(false)
			return
		}
		_dismiss(stage: stage, actor: actor, from: destination, animated: animated, completion: completion)
	}

	private func unwind(stage: Stage, actor: SceneActing, source: UIViewController?, destination: UIViewController?, animated: Bool,  completion: Transition.Completion?) -> Void {
		guard let source = source else {
			assertionFailureOrPrint("Failed to get source view controller for \(SystemTransition.unwind)")
			completion?(false)
			return
		}
		guard let destination = destination else {
			assertionFailureOrPrint("Failed to get destination view controller for \(SystemTransition.unwind)")
			completion?(false)
			return
		}

		var blocks = [()->Void]()
		blocks.append {
			CATransaction.begin()
			CATransaction.setCompletionBlock({
				completion?(true)
			})
		}

		let arrived = _unwind(from: source, to: destination, addingOperationsTo: &blocks, animated: animated)
		guard let _ = arrived else {
			assertionFailureOrPrint("Failed to find destination after unwinding all stacks from \(source)")
			completion?(false)
			return
		}

		blocks.append {
			CATransaction.commit()
		}

		for block in blocks {
			block()
		}

		actor.destination = destination
		completion?(true)
	}
}

private func _unwind(from node: UIViewController, to destination: UIViewController, addingOperationsTo blocks: inout [()->Void], animated: Bool) -> UIViewController? {
	if let nav = node.navigationController, nav.viewControllers.contains(destination)  {
		blocks.append {
			_ = nav.popToViewController(destination, animated: animated)
		}
		return destination
	}
	if let presenter = node.presentingViewController {
		blocks.append {
			presenter.dismiss(animated: animated, completion: nil)
		}
		if presenter == destination {
			return presenter
		} else {
			for child in presenter.children {
				if child == destination {
					return destination
				}
				if let presentingNav = child as? UINavigationController, presentingNav.viewControllers.contains(destination) {
					return _unwind(from: presentingNav, to: destination, addingOperationsTo: &blocks, animated: animated)
				}
			}
		}
		return _unwind(from: presenter, to: destination, addingOperationsTo: &blocks, animated: animated)
	}
	if let parent = node.parent {
		if parent == destination {
			return parent
		}
		if let parent = parent.parent {
			return _unwind(from: parent, to: destination, addingOperationsTo: &blocks, animated: animated)
		}
	}
	return nil
}


