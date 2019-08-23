//
//  Stage.swift
//  StoryKit
//
//  Created by John Clayton on 8/22/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

public typealias Ovation = (UIViewController?)->Void

public enum Event {
	case next(Bool)
	case error(Error)
	case completed
}

public protocol Condition {
	func observe(eventBlock: @escaping (Event)->Void)
}

public class Stage {
	public let window: UIWindow
	public var registeredScripts: [Script] {
		let registeredScripts = scripts
		return registeredScripts
	}

	public init(window: UIWindow) throws {
		self.window = window
		if let rootViewController = window.rootViewController {
			try rootViewController.sceneDescriptor.registerInBoard(viewController: rootViewController)
		}
	}

	@discardableResult public func register(scriptAndInitialize initializer: (Script) -> Void) -> Script {
		let script = Script(stage: self)
		register(script: script)
		initializer(script)
		return script
	}

	public func register(script: Script) {
		scripts.append(script)
	}

	public func perform(_ story: Story, animated: Bool = true, completion: Ovation? = nil ) {
		let director = Director(stage: self, story: story, animated: animated, completion: completion)
		let directors = performanceQueue.operations.filter { $0 is Director }
		if let previousDirector = directors.last {
			let pipe = previousDirector.passTo(director) {
				director.beginning = self.story
				self.performanceQueue.addOperations(director.actors, waitUntilFinished: false)
			}
			performanceQueue.addOperation(pipe)
		} else {
			director.beginning = self.story
			performanceQueue.addOperations(director.actors, waitUntilFinished: false)
		}

		director.onProgress = { story in
			self.currentPerformance = story
		}

		performanceQueue.addOperation(director)
	}

	public func insert(_ story: Story) {
		performanceQueue.isSuspended = true
		defer {
			performanceQueue.isSuspended = false
		}
		let editor = Editor(stage: self, beginning: self.story, ending: story)

		var operations = editor.dependencies
		operations.append(editor)

		for operation in operations  {
			operation.start()
		}
	}

	public var story: Storyish {
		do {
			return try staticStory(fromNode: window.rootViewController, transition: SystemTransition.root)
		} catch {
			assertionFailureOrPrint("Could not derive current story from UI state \(error)")
			return StaticStory()
		}
	}

	private func staticStory<T: TransitionProtocol>(fromNode node: UIViewController?, transition: T) throws -> StaticStory {
		let scenes: [SceneProtocol] = try staticScenes(fromNode: node, transition: transition)
		return StaticStory(scenes)
	}

	private func staticScenes<T: TransitionProtocol>(fromNode node: UIViewController?, transition: T) throws -> [StaticScene] {
		var scenes = [StaticScene]()

		guard let node = node else { return scenes }

		let descriptor = node.sceneDescriptor

		let scene = StaticScene(descriptor: descriptor, viewController: node, transition: transition)
		scenes.append(scene)

		switch node {
		case let tabs as UITabBarController:
			scenes += try staticScenes(fromNode: tabs.selectedViewController, transition: SystemTransition.select)
		case let nav as UINavigationController:
			let stack = nav.viewControllers
			for stackedNode in stack {
				let transition = stackedNode == stack.first ? SystemTransition.set: SystemTransition.push
				scenes += try staticScenes(fromNode: stackedNode, transition: transition)
			}
		default:
			if let presentedNode = node.presentedViewController {
				scenes += try staticScenes(fromNode: presentedNode, transition: SystemTransition.present)
			}
		}

		return scenes
	}

	private var scripts = [Script]()

	private lazy var performanceQueue = { () -> OperationQueue in
		let q = OperationQueue()
		q.underlyingQueue = DispatchQueue.main
		q.name = "StoryKit.performanceQueue"
		q.qualityOfService = .userInitiated
		q.maxConcurrentOperationCount = 1
		return q
	}()
	private var currentPerformance: Storyish?
}

//MARK: URL Handling

public extension Stage {
	public func perform(url: URL, animated: Bool = true, completion: Ovation? = nil ) {
		guard let story = story(matchingURL: url) else {
			completion?(nil)
			return
		}
		perform(story, animated: animated, completion: completion)
	}

	func story(matchingURL url: URL) -> Story? {
		// Starting with url.pathComponents, for each component:
		// 	- look at each script's corresponding path scene (not all scenes contribute to the path, such as junction scenes) for each registered script
		// 	- match match each scene to the current component, for input captures, match to any data in the component (e.g. /123/)
		// Do this breadth first and reduce: slice off the first component, and return scripts with matching scenes at that depth, then slice off the next components one level deeper anre repeat until no more components exist.
		// See if you have a match (there will only be one or none because url uniqueness is based on segments that resolve to a leaf)
		//
		// Example:
		// 	Matching URL "/foo/bar/bat/bing" against scripts like (/foo, /foo/bar/bam/bappo, /foo/bar/bat/zing, /foo/bar/bat/bing) will reduce the candidate scripts this way until there is only one:
		// 	foo: - - - - - - -
		// 	bar:   - - - - -
		// 	bat:     - - -
		// 	bing:      -
		let components = url.pathComponents
		print(components)
		let matchingScripts: [Script] = url.pathComponents.enumerated().reduce(Array<Script>(scripts)) { candidateScripts, eachComponent in
			let (index, segment) = eachComponent
			return candidateScripts.filter({ script in
				let pathScenes = script.pathScenes
				guard index < pathScenes.count else {
					return false
				}
				let sceneAtIndex = pathScenes[index]
				let matches = sceneAtIndex.matches(string: segment)
				return matches
			})
		}
		assertOrPrint((0...1).contains(matchingScripts.count), "Ambiguous script match for url (\(url)). There can be only one (or none). Examine your scripts to see where you are creating duplicate paths. \(matchingScripts)")
		do {
			return try matchingScripts.first?.bind(pathSegments: url.pathComponents).asStory()
		} catch {
			assertionFailureOrPrint("Screwed up binding path segments to script: \(error)")
			return nil
		}
	}
}



public extension Stage  {
	func segue(toScene scene: SceneDescriptor?, transition: TransitionProtocol, source: SceneDescriptor? = nil, unlessConditionMet condition: Condition? = nil) -> Story {
		return Story(stage: self).segue(toScene: scene, transition: transition, source: source, unlessConditionMet: condition)
	}

	@discardableResult func root(_ scene: SceneDescriptor, unlessConditionMet condition: Condition? = nil) -> Story {
		return segue(toScene: scene, transition: SystemTransition.root, unlessConditionMet: condition)
	}

	@discardableResult func select(_ scene: SceneDescriptor, unlessConditionMet condition: Condition? = nil) -> Story {
		return segue(toScene: scene, transition: SystemTransition.select, unlessConditionMet: condition)
	}

	@discardableResult func set(_ scene: SceneDescriptor, unlessConditionMet condition: Condition? = nil) -> Story {
		return segue(toScene: scene, transition: SystemTransition.set, unlessConditionMet: condition)
	}

	@discardableResult func embed(_ scene: SceneDescriptor, in containing: SceneDescriptor, unlessConditionMet condition: Condition? = nil) -> Story {
		return segue(toScene: scene, transition: SystemTransition.embed, source: containing, unlessConditionMet: condition)
	}

	@discardableResult func push(_ scene: SceneDescriptor, unlessConditionMet condition: Condition? = nil) -> Story {
		return segue(toScene: scene, transition: SystemTransition.push, unlessConditionMet: condition)
	}

	@discardableResult func pop(unlessConditionMet condition: Condition? = nil) -> Story {
		return segue(toScene: nil, transition: SystemTransition.pop, unlessConditionMet: condition)
	}

	@discardableResult func pop(to scene: SceneDescriptor?, unlessConditionMet condition: Condition? = nil) -> Story {
		return segue(toScene: scene, transition: SystemTransition.popTo, unlessConditionMet: condition)
	}

	@discardableResult func popToRoot(unlessConditionMet condition: Condition? = nil) -> Story {
		return segue(toScene: nil, transition: SystemTransition.popToRoot, unlessConditionMet: condition)
	}

	@discardableResult func present(_ scene: SceneDescriptor, from presenting: SceneDescriptor? = nil, unlessConditionMet condition: Condition? = nil) -> Story {
		return segue(toScene: scene, transition: SystemTransition.present, source: presenting, unlessConditionMet: condition)
	}

	@discardableResult func dismiss(unlessConditionMet condition: Condition? = nil) -> Story {
		return segue(toScene: nil, transition: SystemTransition.dismiss, unlessConditionMet: condition)
	}

	@discardableResult func dismiss(from scene: SceneDescriptor, unlessConditionMet condition: Condition? = nil) -> Story {
		return segue(toScene: scene, transition: SystemTransition.dismiss, unlessConditionMet: condition)
	}

	@discardableResult func unwind(to scene: SceneDescriptor, unlessConditionMet condition: Condition? = nil) -> Story {
		return segue(toScene: scene, transition: SystemTransition.unwind, unlessConditionMet: condition)
	}
}
