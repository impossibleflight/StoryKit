//
//  Tags.swift
//  StoryKitDemo
//
//  Created by John Clayton on 12/30/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//
import UIKit
import StoryKit

enum Tags {
	case root
	case tags
	case tag(name: String)
}

extension Tags: StoryboardSceneDescriptor {
	func sceneController() throws -> UIViewController {
		switch self {
		case .root, .tags:
			return try sceneControllerFromStoryboard()
		case let .tag(name: tag):
			return try sceneControllerFromStoryboard() { (controller: TagViewController) in
				let model = TagViewController.ViewModel(tag: tag)
				controller.viewModel = model
			}
		}
	}

	static var restorationIdentifiers: [Tags] {
		return [ .root , .tags ]
	}
}


