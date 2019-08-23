// GENERATED FILE. DO NOT EDIT.
import UIKit
import StoryKit

enum Favorites {
	case favorites
	case favorite(favoriteID: Int)
}

extension Favorites: StoryboardSceneDescriptor {
	func sceneController() throws -> UIViewController {
		switch self {
		case .favorites:
			return try sceneControllerFromStoryboard(inScope: .container)
		case let .favorite(favoriteID: favoriteID):
			return try sceneControllerFromStoryboard() { (controller: PhotoViewController) in
				let model = PhotoViewController.ViewModel(favoriteID: favoriteID)
				controller.viewModel = model
			}
		}
	}

	static var restorationIdentifiers: [Favorites] {
		return [.favorites]
	}
}
