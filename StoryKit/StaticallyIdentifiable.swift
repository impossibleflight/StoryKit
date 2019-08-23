//
//  StaticIdentifiable.swift
//  StoryKit
//
//  Created by John Clayton on 10/19/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

fileprivate extension String {
	func snakeCased() -> String? {
		let pattern = "([^A-Z])([A-Z])"
		let regex = try? NSRegularExpression(pattern: pattern, options: [])
		let range = self.startIndex..<self.endIndex
		return regex?.stringByReplacingMatches(in: self, options: [], range: NSRange(range, in: self), withTemplate: "$1_$2").lowercased()
	}
}

protocol StaticallyIdentifiable {
	var staticIdentifier: SceneIdentifier { get }
}

extension UIViewController: StaticallyIdentifiable {
	var staticIdentifier: SceneIdentifier {
		let typeString = String(describing: type(of: self)).snakeCased()!
		if let restorationIdentifier = restorationIdentifier {
			return String(format: "%@_%p_%@", typeString, self, restorationIdentifier)
		} else {
			return String(format: "%@_%p", typeString, self)
		}
	}
}

