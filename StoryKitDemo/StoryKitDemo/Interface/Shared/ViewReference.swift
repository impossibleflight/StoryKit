//
//  XibView.swift
//  StoryKitDemo
//
//  Created by John Clayton on 11/19/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

class ViewReference<ViewType: UIView>: UIView {
	@IBInspectable var nibName: String!

	var referencedView: ViewType!

	func initialize() {

	}

	func ready() {
		loadView()
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

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		loadView()
		referencedView.prepareForInterfaceBuilder()
	}

	func loadView() {
		if nibName == nil {
			nibName = "\(ViewType.self)"
		}
		let bundle = Bundle(for: ViewType.self)
		let nib = UINib(nibName: nibName, bundle: bundle)
		guard let view = nib.instantiate(withOwner: self, options: nil).filter({ $0 is ViewType }).first as? ViewType else {
			assertionFailure("Failed to load view of type \(ViewType.self)")
			return
		}
		view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.translatesAutoresizingMaskIntoConstraints = true
		view.frame = bounds
		self.addSubview(view)
		referencedView = view
	}
}
