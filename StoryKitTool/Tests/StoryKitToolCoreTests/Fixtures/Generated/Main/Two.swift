// This section is automatically generated. DO NOT EDIT.
// storykit:inline:Two.StoryboardSceneDescriptor
import UIKit
import StoryKit

enum Two { 
	case two
	case collection(name: String)
	case table(groupID: Int)
	case picker_list(listIdentifier: UUID)
	case picker
}

extension Two: StoryboardSceneDescriptor {
	func sceneController() throws -> UIViewController {
		switch self { 
		case .two:
			return try sceneControllerFromStoryboard() { (controller: ViewControllerTwo) in
				didLoad(sceneController: controller)
			}
		case let .collection(name):
			return try sceneControllerFromStoryboard() { (controller: TwoCollectionViewController) in
				didLoad(sceneController: controller)
			}
		case let .table(groupID):
			return try sceneControllerFromStoryboard() { (controller: TwoTableViewController) in
				didLoad(sceneController: controller)
			}
		case let .picker_list(listIdentifier):
			return try sceneControllerFromStoryboard() { (controller: TwoPickerListViewController) in
				didLoad(sceneController: controller)
			}
		case .picker:
			return try sceneControllerFromStoryboard() { (controller: UIViewController) in
				didLoad(sceneController: controller)
			}
		}
	}

	static var restorationIdentifiers: [Two] {
		return [
			.two
			,.picker
		]
	}
}
// storykit:end

// This extension may be manually edited
extension Two: SceneControllerInitializing {
	// Perform custom scene controller initialization here.
	func didLoad<V: UIViewController>(sceneController: V) {
		/*
		switch self { 
		case .two:
			// Do any additional setup after loading from storyboard
		case let .collection(name):
			// Do any additional setup after loading from storyboard
			// Like binding controller to the incoming values...
			// controller.name = name
		case let .table(groupID):
			// Do any additional setup after loading from storyboard
			// Like binding controller to the incoming values...
			// controller.groupID = groupID
		case let .picker_list(listIdentifier):
			// Do any additional setup after loading from storyboard
			// Like binding controller to the incoming values...
			// controller.listIdentifier = listIdentifier
		case .picker:
			// Do any additional setup after loading from storyboard
		}
		*/
	}
}