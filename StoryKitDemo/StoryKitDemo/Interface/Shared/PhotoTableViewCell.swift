//
//  PhotoTableViewCell.swift
//  StoryKitDemo
//
//  Created by John Clayton on 11/19/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {
	@IBOutlet var containerView: UIView!
	@IBOutlet var tagsView: TagsView!
	
	var photoView: PhotoView! {
		return (containerView as? PhotoViewReference)?.referencedView
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		tagsView.fontSize = 18.0
	}

	override func prepareForReuse() {
		photoView.prepareForReuse()
		super.prepareForReuse()
	}
}
