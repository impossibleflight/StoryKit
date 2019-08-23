//
//  SceneDesignable.swift
//  StoryKit
//
//  Created by John Clayton on 10/19/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

/// An internal protocol that allows an input signature, e.g. "(String)", to be set in IB which the generator will use to generate the scene descriptor case for the receiver, e.g. <identifier><inputSignature> -> "photos(String)"
protocol SceneDesignable {
	var inputSignature: String? { get }
}

extension UIViewController: SceneDesignable {
	// This is just a stub to let IB generate the value in the storyboard for generator to consume. We don't actually care about the value at runtime.
	@IBInspectable public var inputSignature: String? {
		get { return nil }
		set { }
	}
}



