//
//  UIViewController+StoryKit.swift
//  StoryKit
//
//  Created by John Clayton on 11/28/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit
import Bridge


extension UIViewController: ObjectAssociable { }

private struct StoryboardNibMap {
	static var storyboardPathsByBundle = [Bundle:[String]]()

	static func storyboardPaths(forBundle bundle: Bundle) -> [String] {
		if let storyboardPaths = storyboardPathsByBundle[bundle] {
			return storyboardPaths
		}
		let storyboardPaths = bundle.paths(forResourcesOfType: "storyboardc", inDirectory: nil)
		storyboardPathsByBundle[bundle] = storyboardPaths
		return storyboardPaths
	}

	static func storyboardName(forNibNamed name: String, bundle: Bundle? = nil) -> String? {
		let bundle = bundle ?? Bundle.main
		let storyboardPaths = self.storyboardPaths(forBundle: bundle)
		var storyboardName: String?
		for path in storyboardPaths {
			let dirName = (path as NSString).lastPathComponent
			if let _ = bundle.path(forResource: name, ofType: "nib", inDirectory: dirName) {
				storyboardName = (dirName as NSString).deletingPathExtension
				break
			}
		}
		return storyboardName
	}
}

private extension UIStoryboard {
	struct Keys {
		static var fileBaseName = "name"
	}
	/// We don't call it name so as not to clash with the private method of the same name and trigger rejections
	var fileBasename: String? {
		return self.value(forKey: Keys.fileBaseName) as? String
	}
}

extension UIViewController {
	var storyboardName: String? {
		// The easy way
		if let storyboardName = self.storyboard?.fileBasename {
			return storyboardName
		}
		// The hard way
		if let nibName = self.nibName {
			return StoryboardNibMap.storyboardName(forNibNamed: nibName, bundle: self.nibBundle)
		}
		return nil
	}
}
