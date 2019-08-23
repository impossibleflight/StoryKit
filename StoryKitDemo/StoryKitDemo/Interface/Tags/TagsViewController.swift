//
//  TagsViewController.swift
//  StoryKitDemo
//
//  Created by John Clayton on 12/30/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

class TagsViewController: UITableViewController {

	struct ViewModel {
		var tags: [String] {
			return Container.instance.state.tags
		}
	}

	let viewModel = ViewModel()
	private let cellIdentifier = "TagCell"


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
		let tag = viewModel.tags[indexPath.row]
		cell.textLabel?.text = tag
        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let tag = viewModel.tags[indexPath.row]
		stage.push(Tags.tag(name: tag)).perform(animated: true)
	}

	@IBAction func cancelTagsAction(_ sender: Any) {
		stage.dismiss().perform(animated: true)
	}
}
