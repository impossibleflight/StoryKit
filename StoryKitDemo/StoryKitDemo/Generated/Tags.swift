// THIS FILE GENERATED BY STORYKIT. DO NOT EDIT.

import UIKit
import StoryKit

enum Tags { 
	case tags(name: String)
	case tag
	case root
}

extension Tags: StoryboardSceneDescriptor {
	func sceneController() throws -> UIViewController {
		switch self { 
		case let .tags(name: String):
			return try sceneControllerFromStoryboard() { (controller: TagsViewController) in
				/*
				// Initialize your custom controller subclass here
				controller.name = name
				*/
			}
		case .tag:
			return try sceneControllerFromStoryboard()
		case .root:
			return try sceneControllerFromStoryboard()
		}
	}

	static var restorationIdentifiers: [Tags] {
		return [
			.tag
			,.root
		]
	}
}