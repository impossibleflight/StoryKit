//
//  PhotoCell.swift
//  TravelerDemo
//
//  Created by John Clayton on 4/21/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit


class PhotoCollectionViewCell: UICollectionViewCell {
	@IBOutlet var containerView: UIView!
	var photoView: PhotoView! {
		return (containerView as? PhotoViewReference)?.referencedView
	}

	override func prepareForReuse() {
		photoView.prepareForReuse()
		super.prepareForReuse()
	}
}
