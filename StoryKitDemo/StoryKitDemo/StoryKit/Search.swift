// GENERATED FILE. DO NOT EDIT.
import UIKit
import StoryKit

enum Search {
	case search
	case results(query: String?)
}

extension Search: StoryboardSceneDescriptor {
	func sceneController() throws -> UIViewController {
		switch self {
		case .results(let query):
			return try sceneControllerFromStoryboard() { (controller: SearchResultsViewController) in
				let model = SearchResultsViewController.ViewModel(query: query)
				controller.viewModel = model
			}
		default:
			return try sceneControllerFromStoryboard(inScope: .container)
		}
	}

	static var restorationIdentifiers: [Search] {
		return [.search]
	}
}
