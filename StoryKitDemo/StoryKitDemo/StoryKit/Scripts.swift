//
//  Scripts.swift
//  StoryKitDemo
//
//  Created by John Clayton on 1/3/19.
//  Copyright © 2019 Impossible Flight, LLC. All rights reserved.
//

import UIKit
import StoryKit

enum Scripts {
	case scripts
	case script(identifier: String)
	case inputsForm(identifier: String)
}

extension Scripts: StoryboardSceneDescriptor {
	func sceneController() throws -> UIViewController {
		switch self {
		case .scripts:
			return try sceneControllerFromStoryboard()
		case .script(let identifier):
			return try sceneControllerFromStoryboard() { (controller: ScriptViewController) in
				let model = ScriptViewController.ViewModel(scriptIdentifier: UUID(uuidString: identifier)!)
				controller.viewModel = model
			}
		case .inputsForm(let identifier):
			return try sceneControllerFromStoryboard() { (controller: ScriptFormViewController) in
				let model = ScriptFormViewController.ViewModel(scriptIdentifier: UUID(uuidString: identifier)!)
				controller.viewModel = model
			}
		}
	}

	static var restorationIdentifiers: [Scripts] {
		return [.scripts]
	}
}


