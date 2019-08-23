//
//  Story.swift
//  StoryKit
//
//  Created by John Clayton on 8/22/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit


public protocol Performable {
	func insert()
	func perform(animated: Bool, completion: Ovation?)
}

public protocol Composable {
	@discardableResult func append(_ scene: AnyScene) -> Self
}

extension Composable {
	@discardableResult func append(_ scene: SceneProtocol) -> Self {
		return self.append(scene.asAnyScene())
	}
}

public protocol Storyish: class, CustomStringConvertible {
	var scenes: [AnyScene] { get }
	var base: Storyish? { get }
	var stage: Stage? { get }

	// Returns a cleaned up version with relative plot lines resolved
	func proofed() -> Self
}

extension Storyish {
	public func proofed() -> Self {
		return self
	}
	func proofedScenes() -> [AnyScene] {
		return scenes
	}
}

public extension Storyish {
	var description: String {
		let address = Int(bitPattern: ObjectIdentifier(self))
		return String(format: "<%@ %0llx> scenes = %@", String(describing: Self.self), address, proofedScenes())
	}
	var shorthand: String {
		return proofedScenes().map({ $0.shorthand }).joined(separator: ", ")
	}
 }

func ==(lhs: Storyish, rhs: Storyish) -> Bool {
	return lhs.proofed().scenes == rhs.proofed().scenes
}

func !=(lhs: Storyish, rhs: Storyish) -> Bool {
	return !(lhs == rhs)
}

extension Storyish {
	func isSubplot(of parent: Storyish) -> Bool {
		let child = self
		return child.scenes.starts(with: parent.scenes) && child.scenes.count > parent.scenes.count
	}

	func isSuperplot(of child: Storyish) -> Bool {
		let parent = self
		return child.scenes.starts(with: parent.scenes) && child.scenes.count > parent.scenes.count
	}

	func plotting(to story: Storyish) -> Story? {
		guard story != self else {
			return Story(self)
		}
		if self.isSuperplot(of: story) {
			/// If the receiver is the super-plot of story, the result is story minus our scenes
			/// 	/foo/bar => /foo/bar/bing -> ./bing(base = /foo/bar)
			let remainder = story.scenes.filter { !(scenes.contains($0)) }
			return Story(Array(remainder), base: self, stage: self.stage)
		} else if self.isSubplot(of: story) {
			/// If the receiver is a sub-plot of story, the result is a relative story with the receiver as base
			/// 	/foo/bar/bing => /foo/bar -> ../(base = /foo/bar)
			let remainder = self.scenes.filter { !(story.scenes.contains($0)) }
			var inverseScenes = [AnyScene]()
			for scene in remainder {
				do {
					let inverse = try scene.inverse()
					inverseScenes.append(inverse.asAnyScene())
				} catch {
					return nil
				}
			}
			return Story(inverseScenes, base: self, stage: self.stage)
		} else if let otherBase = story.base, otherBase == self {
			/// If story is relative to the receiver, the result is story
			/// 	/foo/bar => ../(base = /foo/bar) -> ../(base = /foo/bar)
			return Story(story)
		} else if let myBase = self.base, myBase == story {
			/// If the receiver is relative to story, then the result is the inverse of the receiver, resulting in story
			/// 	./bing(base = /foo/bar) => /foo/bar -> ../(base = ./bing)
			/// 	../bing(base = /foo/bar) => /foo/bar -> ../bar(base = ../bing)
			fatalError("Unimplemented")
		} else {
			/// If the receiver is neither super- nor sub-plot and neither is relative to the other, the result is story
			/// 	/foo/bar => /boom -> /boom
			return Story(story)
		}
	}

	func relative(to story: Storyish) -> Story {
		guard story != self else {
			return Story(self)
		}

		if self.isSubplot(of: story) {
			/// Plotting sub-plot relative to super-plot results in sub-plot
			/// 	/foo/bar/bing >| /foo/bar -> /foo/bar/bing
			return Story(self)
		} else if self.isSuperplot(of: story) {
			/// Plotting super-plot relative to sub-plot results in super-plot
			/// 	/foo/bar >| /foo/bar/bing -> /foo/bar
			return Story(self)
		} else if let myBase = self.base, myBase == story {
			/// If the receiver is relative to base, then the result is the receiver applied to base
			/// 	./bing(base = /foo/bar) >| /foo/bar -> /foo/bar/bing
			/// 	../bing(base = /foo/bar) >| /foo/bar -> /foo/bing
			return Story(proofedScenes())
		} else if let otherBase = story.base, otherBase == self {
			/// If story is relative to the receiver, the result is the receiver
			/// /foo/bar >| ../(base = /foo/bar) -> /foo/bar
			return Story(self)
		} else {
			/// If the receiver is neither super- nor sub-plot and neither is relative to the other, the result is story
			/// /boom >| /foo/bar -> /boom
			return Story(self)
		}
	}
}

class StaticStory: Storyish {
	private(set) var scenes = [AnyScene]()
	let base: Storyish? = nil
	let stage: Stage? = nil

	init(_ scenes: [AnyScene]) {
		self.scenes = scenes
	}

	convenience init(_ scenes: [SceneProtocol] = []) {
		let anyScenes = scenes.map { $0.asAnyScene() }
		self.init(anyScenes)
	}

	convenience init(_ scene: AnyScene) {
		self.init([scene])
	}

	convenience init(_ scene: SceneProtocol) {
		self.init([scene.asAnyScene()])
	}
}

extension StaticStory: Composable {
	@discardableResult func append(_ scene: AnyScene) -> Self {
		scenes.append(scene)
		return self
	}
}

public final class Story: Storyish {
	private(set) public var scenes = [AnyScene]()
	private(set) public var base: Storyish?
	public var stage: Stage?

	init(_ scenes: [AnyScene] = [], base: Storyish? = nil, stage: Stage? = nil) {
		self.scenes = scenes
		self.stage = stage
		self.base = base
	}

	convenience init(_ story: Storyish) {
		self.init(story.scenes, base: story.base, stage: story.stage)
	}

	convenience init(_ scenes: [SceneProtocol] = [], base: Storyish? = nil, stage: Stage? = nil) {
		let anyScenes = scenes.map { $0.asAnyScene() }
		self.init(anyScenes, base: base, stage: stage)
	}

	convenience init(_ scene: AnyScene, base: Storyish? = nil, stage: Stage? = nil) {
		self.init([scene], base: base, stage: stage)
	}

	convenience init(_ scene: SceneProtocol, base: Storyish? = nil, stage: Stage? = nil) {
		self.init([scene.asAnyScene()], base: base, stage: stage)
	}

	public func proofed() -> Story {
		return Story(proofedScenes(), base: base, stage: stage)
	}

	func proofedScenes() -> [AnyScene] {
		var normalizedScenes = base?.scenes ?? []
		for scene in self.scenes {
			switch scene.transition.direction {
			case .forward:
				normalizedScenes.append(scene)
			case .backward:
				if !normalizedScenes.isEmpty {
					normalizedScenes.removeLast()
				} else {
					normalizedScenes.append(scene)
				}
			}
		}
		return normalizedScenes
	}
}

extension Story: Performable {
	public func insert() {
		stage?.insert(self)
	}
	public func perform(animated: Bool = true, completion: Ovation? = nil ) {
		stage?.perform(self, animated: animated, completion: completion)
	}
}

extension Story: Composable {
	@discardableResult public func append(_ scene: AnyScene) ->  Self {
		let previousScene = scenes.last
		scenes.append(scene)
		if previousScene != nil && previousScene!.transition.isJunction {
			previousScene!.junctionWith = scene
		}
		return self
	}
}

extension Story: Narratable {
	public func segue(toScene scene: SceneDescriptor?, transition: TransitionProtocol, source: SceneDescriptor? = nil, unlessConditionMet condition: Condition? = nil) -> Self {
		return self.append(Scene(descriptor: scene, transition: transition, source: source, condition: condition).asAnyScene())
	}
}


//MARK: Operators


infix operator =>
/// SeeAlso: plotting(to:)
func => (lhs: Storyish, rhs: Storyish) -> Story? {
	return lhs.plotting(to: rhs)
}

infix operator >|
/// SeeAlso: relative(to:)
func >| (lhs: Storyish, rhs: Storyish) -> Story {
	return lhs.relative(to: rhs)
}

infix operator ~>
/// SeeAlso: isSuperplot(of:)
func ~> (lhs: Storyish, rhs: Storyish) -> Bool {
	return lhs.isSuperplot(of: rhs)
}

infix operator <~
/// SeeAlso: isSubplot(of:)
func <~ (lhs: Storyish, rhs: Storyish) -> Bool {
	return lhs.isSubplot(of: rhs)
}
