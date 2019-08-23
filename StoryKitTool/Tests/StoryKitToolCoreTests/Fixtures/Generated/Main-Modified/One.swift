// This section is automatically generated. DO NOT EDIT.
// storykit:inline:One.StoryboardSceneDescriptor
import UIKit
import StoryKit

enum One { 
	case one
	case detail(identifier: String)
}

extension One: StoryboardSceneDescriptor {
	func sceneController() throws -> UIViewController {
		switch self { 
		case .one:
			return try sceneControllerFromStoryboard() { (controller: ViewControllerOne) in
				didLoad(sceneController: controller)
			}
		case let .detail(identifier):
			return try sceneControllerFromStoryboard() { (controller: OneDetailViewController) in
				didLoad(sceneController: controller)
			}
		}
	}

	static var restorationIdentifiers: [One] {
		return [
			.one
		]
	}
}
// storykit:end

// This extension may be manually edited
extension One: SceneControllerInitializing {
	// Perform custom scene controller initialization here.
	func didLoad<V: UIViewController>(sceneController: V) {
		/*
		switch self { 
		case .one:
			// Do any additional setup after loading from storyboard
		case let .detail(identifier):
			// Do any additional setup after loading from storyboard
			// Like binding controller to the incoming values...
			// controller.identifier = identifier
		}
		*/
	}
}