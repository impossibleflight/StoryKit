// THIS FILE GENERATED BY STORYKIT. DO NOT EDIT.

import UIKit
import StoryKit

enum Login { 
	case login
}

extension Login: StoryboardSceneDescriptor {
	func sceneController() throws -> UIViewController {
		switch self { 
		case .login:
			return try sceneControllerFromStoryboard()
		}
	}

	static var restorationIdentifiers: [Login] {
		return [
			.login
		]
	}
}