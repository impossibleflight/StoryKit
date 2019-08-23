//
//  Container.swift
//  StoryKitDemo
//
//  Created by John Clayton on 10/19/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import Foundation
import StoryKit

class Container {

	private struct Keys {
		static var kUserDefaultLastTab = "lastTab"
	}

	static let instance = Container()
	private init() {}


	lazy var state: State = State()
	var stage: Stage!
	lazy var defaults = UserDefaults.standard

	var lastTab: SceneDescriptor? = {
		let defaults = UserDefaults.standard
		if let name = defaults.string(forKey: Keys.kUserDefaultLastTab) {
			return Main.by(restorationIdentifier: name)
		}
		return nil
	}() {
		didSet {
			if let value = lastTab {
				defaults.set(value.name, forKey: Keys.kUserDefaultLastTab)
			}
		}
	}

}

extension Main {
}
