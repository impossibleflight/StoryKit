//
//  Editor.swift
//  StoryKit
//
//  Created by John Clayton on 1/13/19.
//  Copyright © 2019 Impossible Flight, LLC. All rights reserved.
//

import UIKit

class Editor: Operation {
	private(set) var ending: Story
	private(set) var beginning: Storyish

	init(stage: Stage, beginning: Storyish, ending: Story) {
		self.stage = stage
		self.beginning = beginning
		self.ending = ending
		super.init()
		buildEDL()
	}

	func buildEDL() {
		guard let plotToEnding = beginning.plotting(to: ending) else { return }

		var previousEdit: Edit? = nil
		for scene in plotToEnding.scenes {
			let edit: Edit = Edit(stage: stage, scene: scene, story: plotToEnding)
			if let previousEdit = previousEdit {
				edit.addDependency(previousEdit)
			} else {
				do {
					if let source = try beginning.scenes.last?.destinationSceneController() {
						edit.dynamicSource = source
					}
				} catch {
					assertionFailureOrPrint(String(describing: error))
				}
			}
			previousEdit = edit
		}
		if let previousEdit = previousEdit {
			self.addDependency(previousEdit)
		}
	}

	override func main() {
		// Work is done by edit operations
	}

	class func keyPathsForValuesAffectingIsReady() -> Set<String> {
		return ["beginning"]
	}

	private var stage: Stage
}

class Edit: Operation, SceneActing {
	private(set) var scene: AnyScene
	private(set) var story: Story

	func sourceOverride() throws -> UIViewController? {
		return try scene.sourceSceneController()
	}
	var dynamicSource: UIViewController?
	var destination: UIViewController!

	var previousEdit: Edit? {
		return self.dependencies.first as? Edit
	}

	init(stage: Stage, scene: AnyScene, story: Story) {
		self.stage = stage
		self.scene = scene
		self.story = story
		super.init()
	}

	override func main() {
		if let previousEdit = previousEdit {
			dynamicSource = previousEdit.destination
		}
		do {
			destination = try scene.destinationSceneController()
			var source = try sourceOverride()
			if source == nil {
				source = dynamicSource
			}
			scene.transition.worker(stage, self, source, destination, false, nil)
		}
		catch {
			// We don't consider this to be fatal in release builds because the UI will still be left in some state that the user might potentially recover from.
			assertionFailureOrPrint(String(describing: error))
		}
	}

	private var stage: Stage
}

