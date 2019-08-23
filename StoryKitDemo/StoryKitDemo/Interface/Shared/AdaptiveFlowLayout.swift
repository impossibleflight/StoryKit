//
//  AdaptiveFlowLayout.swift
//  StoryKitDemo
//
//  Created by John Clayton on 12/30/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

class AdaptiveFlowLayout: UICollectionViewFlowLayout {

	var itemsPerRow = 3
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override var itemSize: CGSize {
		get {
			if let collectionView = collectionView {
				let bounds = collectionView.bounds
				let width = bounds.size.width
				let interItemSpacing = minimumInteritemSpacing
				let totalSpacing = CGFloat(interItemSpacing*CGFloat(itemsPerRow+1))
				let layoutWidth = Float(width-totalSpacing)
				let itemWidth = CGFloat(floorf(layoutWidth/3.0))
				let itemSize = CGSize(width: itemWidth, height: itemWidth)
				return itemSize
			}
			return super.itemSize
		}
		set {
			super.itemSize = newValue
		}
	}
}
