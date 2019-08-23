//
//  AutoSizingTableView.swift
//  StoryKitDemo
//
//  Created by John Clayton on 1/9/19.
//  Copyright © 2019 Impossible Flight, LLC. All rights reserved.
//

import UIKit

class AutoSizingTableView: UITableView {
	override var intrinsicContentSize: CGSize {
		self.layoutIfNeeded()
		return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
	}
}
