//
//  ScriptViewController.swift
//  StoryKitDemo
//
//  Created by John Clayton on 1/4/19.
//  Copyright © 2019 Impossible Flight, LLC. All rights reserved.
//

import UIKit
import StoryKit

class ScriptViewController: UIViewController, ContainingController {
	struct ViewModel {
		var script: Script
		init(scriptIdentifier: UUID) {
			script = Container.instance.stage.registeredScripts.filter({ script in
				return script.identifier == scriptIdentifier
			}).first!
		}
	}

	var viewModel: ViewModel!
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var pathLabel: UILabel!
	@IBOutlet var containerView: UIView!

	var formViewController: ScriptFormViewController! {
		return self.children.compactMap({ $0 as? ScriptFormViewController }).first!
	}

	override func loadView() {
		super.loadView()
		stage.embed(Scripts.inputsForm(identifier: viewModel.script.identifier.uuidString), in: self.sceneDescriptor).insert()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = viewModel.script.name
		pathLabel.text = viewModel.script.pathRepresentation
	}

	@IBAction func performAction(_ sender: Any) {
		let values = formViewController.values()
		if validate(values: values) {
			do {
				try viewModel.script.bind(inputs: values).perform(animated: true)
			} catch {
				assertionFailure("Error performing script! \(viewModel.script) \(error)")
			}
		}
	}

	@IBAction func openAsURLAction(_ sender: Any) {
		let values = formViewController.values()
		if validate(values: values) {
			do {
				let path = try viewModel.script.bind(inputs: values).pathRepresentation
				let url = URL(string: "storykit://\(path)")!
				let alert = UIAlertController(title: url.absoluteString, message: nil, preferredStyle: .actionSheet)
				alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { _ in
					UIApplication.shared.open(url, options: [:]) { (success) in
						print(success)
					}
				}))
				alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { _ in
					let pasteboard = UIPasteboard(name: .general, create: false)
					pasteboard?.string = url.absoluteString
				}))
				alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
				// You could do this manually without any issue
				//		self.present(alert, animated: true, completion: nil)
				// Or use the stage
				stage.present(alert.sceneDescriptor).perform(animated: true)
			} catch {
				assertionFailure("Error performing script! \(viewModel.script) \(error)")
			}
		}
	}

	private func validate(values: [String]) -> Bool {
		var valid = true
		do {
			for ((label: label, pattern: pattern), value) in zip(viewModel.script.captureSegments, values) {
				let regularExpression = try NSRegularExpression(pattern: pattern, options: [])
				if regularExpression.rangeOfFirstMatch(in: value, options: [.anchored], range: NSMakeRange(0, (value as NSString).length)).location == NSNotFound {
					let alert = UIAlertController(title: "Error", message: "Input (\(value)) for segment (\(label)) did not match pattern (\(pattern))", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "OK", style: .default))
					valid = false
					DispatchQueue.main.async {
						self.present(alert, animated: true)
					}
					break
				}
			}
		} catch {
			assertionFailure(String(describing: error))
			valid = false
		}
		return valid
	}
}
