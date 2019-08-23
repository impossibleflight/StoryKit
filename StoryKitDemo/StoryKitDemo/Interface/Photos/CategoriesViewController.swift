//
//  CategoriesViewController.swift
//  StoryKitDemo
//
//  Created by John Clayton on 9/28/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

class CategoriesViewController: UITableViewController {
	struct ViewModel {
		var categories: [Category] {
			return Container.instance.state.categories
		}
	}

	let viewModel = ViewModel()
	private let cellIdentifier = "CategoryCell"

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.categories.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
		let category = viewModel.categories[indexPath.row]
		cell.textLabel?.text = category.name
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let category = viewModel.categories[indexPath.row]
		stage.push(Photos.photosForCategory(categoryName: category.name)).perform()
		

	}

}

