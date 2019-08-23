//
//  ScriptsViewController.swift
//  StoryKitDemo
//
//  Created by John Clayton on 1/3/19.
//  Copyright © 2019 Impossible Flight, LLC. All rights reserved.
//

import UIKit

import StoryKit

class ScriptsViewController: UITableViewController {

	struct ViewModel {
		var scripts: [Script] {
			return Container.instance.stage.registeredScripts
		}
	}

	let viewModel = ViewModel()
	private let cellIdentifier = "ScriptCell"


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.scripts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
		let script = viewModel.scripts[indexPath.row]
		cell.textLabel?.text = script.name
		cell.detailTextLabel?.text = script.pathRepresentation

        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let script = viewModel.scripts[indexPath.row]
		stage.push(Scripts.script(identifier: script.identifier.uuidString)).perform(animated: true)
	}
}
