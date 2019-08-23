// This section is automatically generated. DO NOT EDIT.
// storykit:inline:Main.StoryboardSceneDescriptor
import UIKit
import StoryKit

enum Main { 
	case root
	case one
	case two
	case three
}

extension Main: StoryboardSceneDescriptor {
	func sceneController() throws -> UIViewController {
		switch self { 
		case .root:
			return try sceneControllerFromStoryboard(inScope: .container ) { (controller: RootViewController) in
				didLoad(sceneController: controller)
			}
		case .one:
			return try sceneControllerFromStoryboard(inScope: .container ) { (controller: UIViewController) in
				didLoad(sceneController: controller)
			}
		case .two:
			return try sceneControllerFromStoryboard(inScope: .container ) { (controller: UIViewController) in
				didLoad(sceneController: controller)
			}
		case .three:
			return try sceneControllerFromStoryboard(inScope: .container ) { (controller: UIViewController) in
				didLoad(sceneController: controller)
			}
		}
	}

	static var restorationIdentifiers: [Main] {
		return [
			.root
			,.one
			,.two
			,.three
		]
	}
}
// storykit:end

// This extension may be manually edited
extension Main: SceneControllerInitializing {
	// Perform custom scene controller initialization here.
	func didLoad<V: UIViewController>(sceneController: V) {
		/*
		switch self { 
		case .root:
			// Do any additional setup after loading from storyboard
		case .one:
			// Do any additional setup after loading from storyboard
		case .two:
			// Do any additional setup after loading from storyboard
		case .three:
			// Do any additional setup after loading from storyboard
		}
		*/
	}
}