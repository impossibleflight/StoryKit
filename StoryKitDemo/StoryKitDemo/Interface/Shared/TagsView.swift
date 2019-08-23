//
//  TagsView.swift
//  StoryKitDemo
//
//  Created by John Clayton on 11/20/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

class TagsView: UIView {

	let padding: CGFloat = 8
	var fontSize: CGFloat = 24.0 {
		didSet {
			setNeedsLayout()
		}
	}

	var tags: [String] = [] {
		didSet {
			for subview in subviews {
				subview.removeFromSuperview()
			}
			for tag in tags {
				let label = PaddedLabel()
				label.font = UIFont.boldSystemFont(ofSize: fontSize)
				label.text = tag
				label.backgroundColor = UIColor(white: 0.90, alpha: 1.0)
				label.layer.cornerRadius = fontSize*0.2
				label.clipsToBounds = true
				self.addSubview(label)
			}
			self.setNeedsLayout()
		}
	}

	func initialize() {
	}

	func ready() {

	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.initialize()
		self.ready()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.initialize()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		self.ready()
	}


	override func layoutSubviews() {
		super.layoutSubviews()

		let containerWidth = self.bounds.size.width

		var x = CGFloat(padding), y = CGFloat(padding)
		for label in subviews {
			let labelSize = label.intrinsicContentSize
			if x > containerWidth - labelSize.width {
				y += (labelSize.height + padding)
				x = padding
			}
			label.frame = CGRect(x: x, y: y, width: labelSize.width, height: labelSize.height)
			x += (labelSize.width + padding)
		}
	}

	override var intrinsicContentSize: CGSize {
		self.layoutSubviews()
		var size = super.intrinsicContentSize
		if let lastFrame = subviews.last?.frame {
			size.height = lastFrame.maxY
		}
		return size
	}
}
