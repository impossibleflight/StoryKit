// GENERATED FILE. DO NOT EDIT.
import UIKit
import StoryKit

enum Login {
	case login
}

extension Login: StoryboardSceneDescriptor {
	func sceneController() throws -> UIViewController {
		return try self.sceneControllerFromStoryboard()
	}

	static var restorationIdentifiers: [Login] {
		return [.login]
	}
}
