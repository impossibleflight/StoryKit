//
//  UIViewController+StoryKit.swift
//  Story
//
//  Created by John Clayton on 8/16/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit
import Bridge


extension UIStoryboard {
	enum Error: Swift.Error, CustomStringConvertible {
		case missing(name: String)
		case missingViewController(storyboard: UIStoryboard, identifier: String)
		case wrongViewControllerClass(storyboard: UIStoryboard, identifier: String, expectedClass: String, foundClass: String)

		var description: String {
			switch self {
			case let .missing(name):
				return "Could not find a storyboard named '\(name)'"
			case let .missingViewController(storyboard, identifier):
				return "\(storyboard) does not contain a controller for identifier '\(identifier)'"
			case let .wrongViewControllerClass(storyboard, identifier, expectedClass, foundClass):
				return "'\(storyboard)' contains a controller of wrong class (found '\(foundClass)', expected '\(expectedClass)') for identifier '\(identifier)'"
			}
		}
	}

	func instantiateViewController<V: UIViewController>(withIdentifier identifier: String) throws -> V {
		var controller: UIViewController
		do {
			controller = try ObjC.throwingReturn { self.instantiateViewController(withIdentifier: identifier) }
		} catch {
			throw Error.missingViewController(storyboard: self, identifier: identifier)
		}
		if let controller = controller as? V {
			return controller
		}
		throw Error.wrongViewControllerClass(storyboard: self, identifier: identifier, expectedClass: String(describing: V.self), foundClass: String(describing: controller.self))
	}
}
