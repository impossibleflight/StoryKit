//
//  PaddedLabel.swift
//  StoryKitDemo
//
//  Created by John Clayton on 11/20/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

class PaddedLabel: UILabel {
	var padding: CGFloat = 8.0
	override func drawText(in rect: CGRect) {
		let insetRect = rect.insetBy(dx: padding, dy: padding)
		super.drawText(in: insetRect)
	}
	override var intrinsicContentSize: CGSize {
		let size = super.intrinsicContentSize
		return CGSize(width: size.width+(padding*2), height: size.height+(padding*2))
	}
}


