//
//  SearchViewController.swift
//  StoryKitDemo
//
//  Created by John Clayton on 9/28/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
	struct ViewModel {
		var topTags: [String] {
			return Array(Container.instance.state.rankedTags[..<10])
		}
	}

	var viewModel = ViewModel()
	private let cellIdentifier = "PhotoCell"

	@IBOutlet var stackView: UIStackView!
	var searchController: UISearchController!

	override func viewDidLoad() {
        super.viewDidLoad()

		for tag in viewModel.topTags {
			let button = UIButton(type: .custom)
			button.setTitle(tag, for: .normal)
			button.titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
			button.setTitleColor(UIColor.darkText, for: .normal)
			button.addTarget(self, action: #selector(tagButtonAction(sender:)), for: .touchUpInside)
			stackView.addArrangedSubview(button)
		}
		let padding = UIView()
		padding.translatesAutoresizingMaskIntoConstraints = false
		padding.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .vertical)
		stackView.addArrangedSubview(padding)

		if let resultsController = Search.results(query: nil).sceneController as? SearchResultsViewController {
			searchController = UISearchController(searchResultsController: resultsController)
			searchController.searchResultsUpdater = self
			self.navigationItem.searchController = searchController;
			self.navigationItem.hidesSearchBarWhenScrolling = false
			resultsController.tableView.delegate = self
		}
	}

	@objc func tagButtonAction(sender: UIButton) {
		let tag = sender.titleLabel!.text
		self.searchController.searchBar.becomeFirstResponder()
		self.searchController.searchBar.text = tag
	}
}

extension SearchViewController: UISearchResultsUpdating {
	public func updateSearchResults(for searchController: UISearchController) {
		if let resultsController = searchController.searchResultsController as? SearchResultsViewController {
			resultsController.viewModel.query = searchController.searchBar.text
		}
	}
}

extension SearchViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let resultsController = searchController.searchResultsController as? SearchResultsViewController {
			let photo = resultsController.viewModel.photos[indexPath.item]
			stage.push(Photos.photo(identifier: photo.identifier.uuidString)).perform(animated: true) { controller in
				if let photoController = controller as? PhotoViewController {
					photoController.viewModel.context = .search
				}
			}
		}
	}
}
