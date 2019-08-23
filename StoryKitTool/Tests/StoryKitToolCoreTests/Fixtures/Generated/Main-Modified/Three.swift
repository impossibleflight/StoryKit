// This section is automatically generated. DO NOT EDIT.
// storykit:inline:Three.StoryboardSceneDescriptor
import UIKit
import StoryKit

enum Three { 
	case three
}

extension Three: StoryboardSceneDescriptor {
	func sceneController() throws -> UIViewController {
		switch self { 
		case .three:
			return try sceneControllerFromStoryboard() { (controller: UIViewController) in
				didLoad(sceneController: controller)
			}
		}
	}

	static var restorationIdentifiers: [Three] {
		return [
			.three
		]
	}
}
// storykit:end

// This extension may be manually edited
extension Three: SceneControllerInitializing {
	// Perform custom scene controller initialization here.
	func didLoad<V: UIViewController>(sceneController: V) {
		/*
		switch self { 
		case .three:
			// Do any additional setup after loading from storyboard
		}
		*/
	}
}