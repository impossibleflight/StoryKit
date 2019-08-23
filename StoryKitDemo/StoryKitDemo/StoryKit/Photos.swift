// GENERATED FILE. DO NOT EDIT.
import UIKit
import StoryKit

enum Photos {
	case categories
	case photosForCategory(categoryName: String)
	case photo(identifier: String)
}

extension Photos: StoryboardSceneDescriptor {
	func sceneController() throws -> UIViewController {
		switch self {
		case .categories:
			return try sceneControllerFromStoryboard(inScope: .container)
		case let .photosForCategory(categoryName):
			return try sceneControllerFromStoryboard() { (controller: CategoryPhotosViewController) in
				let model = CategoryPhotosViewController.ViewModel(name: categoryName)
				controller.viewModel = model
			}
		case let .photo(identifier):
			return try sceneControllerFromStoryboard() { (controller: PhotoViewController) in
				let model = PhotoViewController.ViewModel(identifier: identifier)
				controller.viewModel = model
			}
		}
	}

	static var restorationIdentifiers: [Photos] {
		return [.categories]
	}
}
