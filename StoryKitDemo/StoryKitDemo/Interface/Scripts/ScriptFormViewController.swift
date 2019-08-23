//
//  FormViewController.swift
//  StoryKitDemo
//
//  Created by John Clayton on 1/8/19.
//  Copyright © 2019 Impossible Flight, LLC. All rights reserved.
//

import UIKit
import StoryKit

private let cellIdentifier = String(describing: FormFieldCell.self)

class ScriptFormViewController: UITableViewController {

	struct ViewModel {
		var segments: [(String, String)] = []
		init(scriptIdentifier: UUID) {
			if let script = Container.instance.stage.registeredScripts.filter({ script in
				return script.identifier == scriptIdentifier
			}).first {
				segments = script.captureSegments
			}
		}
	}

	var viewModel: ViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.rowHeight = 90
		tableView.estimatedRowHeight = 90
		tableView.backgroundColor = .white
		tableView.isScrollEnabled = false
    }

	func values() -> [String] {
		var values = [String]()
		for cell in tableView.visibleCells {
			if let cell = cell as? FormFieldCell, let text = cell.textField.text {
				values.append(text)
			}
		}
		return values
	}

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.segments.count
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FormFieldCell else {
			fatalError("Failed to dequeue cell as \(FormFieldCell.self)")
		}
		let (label, pattern) = viewModel.segments[indexPath.row]
		cell.labelLabel.text = label
		cell.textField.placeholder = pattern

		return cell
    }

    
}
