//
//  Actor.swift
//  StoryKit
//
//  Created by John Clayton on 8/23/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

extension Operation {
	@discardableResult func passTo(_ operation: Operation, using block: @escaping ()->Void) -> BlockOperation {
		let pipe = BlockOperation(block: block)
		pipe.addDependency(self)
		operation.addDependency(pipe)
		return pipe
	}
}

class Performer: Operation {
	enum State {
		case waiting
		case executing
		case finished
	}

	override var isAsynchronous: Bool { return true }

	fileprivate var state = State.waiting {
		willSet {
			willChangeValue(forKey: "state")
		}
		didSet {
			didChangeValue(forKey: "state")
		}
	}

	var waiting: Bool { return state == .waiting }

	override var isExecuting: Bool {
		let isExecuting = state == .executing
		return isExecuting
	}

	override var isFinished: Bool {
		let isFinished = state == .finished
		return isFinished
	}

	override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
		switch key {
		case "isWaiting","isExecuting","isFinished":
			return ["state"]
		default:
			return super.keyPathsForValuesAffectingValue(forKey: key)
		}
	}

	override func start() {
		guard isCancelled == false else { return }
		self.state = .executing
	}
}

class Director: Performer {
	private(set) var animated: Bool
	private(set) var ending: Story

	var beginning: Storyish? {
		didSet {
			actors = assembleCast()
		}
	}

	var onProgress: ((Storyish)->Void)?

	private(set) var story: Storyish? {
		didSet(story) {
			if let story = story {
				onProgress?(story)
			}
		}
	}

	private(set) var actors = [Operation]()


	init(stage: Stage, story: Story, animated: Bool, completion: Ovation? = nil) {
		self.stage = stage
		ending = story
		self.animated = animated
		super.init()
		if let block = completion {
			self.completionBlock = { [weak self] in
				DispatchQueue.main.async {
					block((self?.actors.last as? Actor)?.destination)
				}
			}
		}
	}

	//MARK: Private

	private func assembleCast() -> [Operation] {
		var actors = [Operation]()

		guard let beginning = beginning else {
			return actors
		}

		guard let plotToEnding = beginning.plotting(to: ending) else {
			return actors
		}

		let plotProgress = Story()


		var previousActor: Actor?
		for scene in plotToEnding.scenes {
			let actor: Actor
			if let condition = scene.condition {
				actor = Spectactor(stage: stage, scene: scene, condition: condition, story: plotToEnding, animated: animated)
			} else {
				actor = Actor(stage: stage, scene: scene, story: plotToEnding, animated: animated)
			}

			if let previousActor = previousActor {
				let handoff = previousActor.passTo(actor) {
					actor.dynamicSource = previousActor.destination
				}
				actors.append(handoff)
			} else {
				do {
					if let source = try beginning.scenes.last?.destinationSceneController() {
						actor.dynamicSource = source
					}
				} catch {
					// If the first actor needed a source and didn't get one it will explode later. But, we still want to know that there was an error getting the source for the first scene even if the actor is fine without it.
					assertionFailureOrPrint(String(describing: error))
				}
			}

			actor.completionBlock = {
				plotProgress.append(scene)
				let currentDraft = plotProgress.relative(to: beginning)
				self.story = currentDraft
			}

			actors.append(actor)
			previousActor = actor
		}

		if let previousActor = previousActor {
			self.addDependency(previousActor)
		}

		return actors
	}

	private var stage: Stage
}

//MARK: Director: Operation

extension Director {
	class func keyPathsForValuesAffectingValueForReady() -> Set<String> { return ["actors"] }

	override var isReady: Bool {
		return super.isReady && beginning != nil
	}

	override func start() {
		guard isCancelled == false else { return }
		self.state = .finished
	}

	override func cancel() {
		super.cancel()
		self.actors.forEach { $0.cancel() }
	}
}

public protocol SceneActing: class {
	var destination: UIViewController! { get set }
}

class Actor: Performer, SceneActing {
	fileprivate var stage: Stage
	private(set) var scene: AnyScene
	private(set) var story: Story
	private(set) var animated: Bool

	func sourceOverride() throws -> UIViewController? {
		return try scene.sourceSceneController()
	}
	var dynamicSource: UIViewController?
	var destination: UIViewController!

	var completedTransition: Bool = false

	init(stage: Stage, scene: AnyScene, story: Story, animated: Bool) {
		self.stage = stage
		self.scene = scene
		self.story = story
		self.animated = animated
		super.init()
	}

	override func start() {
		guard isCancelled == false else { return }

		super.start()

		do {
			destination = try scene.destinationSceneController()
			var source = try sourceOverride()
			if source == nil {
				source = dynamicSource
			}
			scene.transition.worker(stage, self, source, destination, animated, { complete in
				self.finishTransition(completed: complete)
			})
		}
		catch {
			// We don't consider this to be fatal in release builds because the UI will still be left in some state that the user might potentially recover from.
			assertionFailureOrPrint(String(describing: error))
			state = .finished
		}
	}

	func finishTransition(completed: Bool) {
		completedTransition = completed
		self.state = .finished
	}
}

class Spectactor: Actor {
	init(stage: Stage, scene: AnyScene, condition: Condition, story: Story, animated: Bool) {
		super.init(stage: stage, scene: scene, story: story, animated: animated)
		condition.observe { [weak self] event in
			guard let self = self else { return }
			switch event {
			case .next(let flag):
				self.conditionValue = flag
			case .error(let error):
				assertionFailureOrPrint("Got error while waiting on condition. \(scene) (\(error))")
				self.state = .finished
			case .completed:
				self.state = .finished
			}
		}
	}

	override func start() {
		guard isCancelled == false else { return }
		guard conditionValue == false else {
			state = .finished
			return
		}
		super.start()
	}

	override func finishTransition(completed: Bool) {
		finishIfConditionSatisfied()
	}

	func finishIfConditionSatisfied() {
		if isExecuting && conditionValue {
			let inverse = scene.transition.inverse
			inverse.worker(stage, self, dynamicSource, destination, animated) { complete in
				self.state = .finished
			}
		}
	}

	private var haveInitialConditionValue: Bool = false
	private var conditionValue = false {
		didSet {
			haveInitialConditionValue = true
			finishIfConditionSatisfied()
		}
	}


	//MARK: Operation

	class func keyPathsForValuesAffectingValueForReady() -> Set<String> { return ["haveInitialConditionValue"] }

	override var isReady: Bool {
		let superIsReady = super.isReady
		return superIsReady && haveInitialConditionValue
	}

}



















