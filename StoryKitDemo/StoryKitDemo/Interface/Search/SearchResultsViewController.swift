//
//  SearchResultsViewController.swift
//  StoryKitDemo
//
//  Created by John Clayton on 9/28/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

private let cellIdentifier = "PhotoCell"

class SearchResultsViewController: UITableViewController {

	struct ViewModel {
		var query: String? {
			didSet {
				onUpdate?(self)
			}
		}
		init(query: String? = nil) {
			self.query = query
		}

		var photos: [Photo] {
			return Container.instance.state.photos(forQuery: query)
		}

		var onUpdate: ((ViewModel)->Void)?
	}

	var viewModel: ViewModel!

	override func viewDidLoad() {
		super.viewDidLoad()
		title = viewModel.query
		tableView.register(UINib(nibName: String(describing: PhotoTableViewCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
		viewModel.onUpdate = { model in
			DispatchQueue.main.async {
				self.title = model.query
				self.tableView.reloadData()
			}
		}
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.photos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PhotoTableViewCell else {
			fatalError("Failed to dequeue cell as \(PhotoTableViewCell.self)")
		}
		let photo = viewModel.photos[indexPath.item]
		cell.photoView.photo = photo
		cell.tagsView.tags = photo.tags
		return cell
    }
}
