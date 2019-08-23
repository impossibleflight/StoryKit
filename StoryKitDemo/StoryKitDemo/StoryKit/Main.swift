// GENERATED FILE. DO NOT EDIT.
import UIKit
import StoryKit

enum Main {
	case root
	case categories
	case search
	case favorites
	case scripts
}

extension Main: StoryboardSceneDescriptor {
	func sceneController() throws -> UIViewController {
		return try self.sceneControllerFromStoryboard(inScope: .container)
	}

	static var restorationIdentifiers: [Main] {
		return [.root, .categories, .search, .favorites, .scripts]
	}
}

