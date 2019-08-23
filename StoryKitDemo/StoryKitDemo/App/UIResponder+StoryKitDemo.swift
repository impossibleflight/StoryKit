//
//  UIResponder+StoryKitDemo.swift
//  StoryKitDemo
//
//  Created by John Clayton on 10/23/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit
import StoryKit

extension UIResponder {
	var stage: Stage {
		return Container.instance.stage
	}
}
