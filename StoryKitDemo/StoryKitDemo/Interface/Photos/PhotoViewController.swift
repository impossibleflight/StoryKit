//
//  PhotoViewController.swift
//  StoryKitDemo
//
//  Created by John Clayton on 9/28/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit
import MobileCoreServices

class PhotoViewController: UIViewController {

	struct ViewModel {
		enum Context {
			case categories, search, favorites
		}
		var photo: Photo? = nil
		var context: Context
		init(identifier: String, context: Context = .categories) {
			if let UUID = UUID(uuidString: identifier) {
				photo = Container.instance.state.photo(withIdentifier: UUID)
			}
			self.context = context
		}
		init(favoriteID: Int, context: Context = .favorites) {
			photo = Container.instance.state.favorite(withID: favoriteID)
			self.context = context
		}
	}
	var viewModel: ViewModel!

	@IBOutlet var imageView: UIImageView!
	@IBOutlet var notFoundPlaceholderLabel: UILabel!
	@IBOutlet var urlLabel: UILabel!
	@IBOutlet var tagsView: TagsView!
	@IBOutlet var heartButton: UIButton!
	@IBOutlet var allTagsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
		guard let photo = viewModel.photo else {
			title = "Photo"
			notFoundPlaceholderLabel.isHidden = false
			allTagsButton.isHidden = true
			heartButton.isHidden = true
			return
		}

		title = photo.identifier.uuidString
		imageView.loadFromURL(photo.url)
		urlLabel.text = photo.url.absoluteString
		heartButton.isHidden = !photo.favorite
		tagsView.tags = photo.tags
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard let photo = viewModel.photo else { return }
		switch viewModel.context {
		case .categories, .search:
			title = photo.identifier.uuidString
		case .favorites:
			title = String(describing: photo.favoriteID!)
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	@IBAction func allTagsAction(_ sender: Any) {
		stage.present(Tags.root).perform(animated: true)
	}

	@IBAction func actionButtonAction(_ sender: Any) {
		guard let photo = viewModel.photo else { return }

		let pasteboard = UIPasteboard(name: .general, create: false)
		let identifier = photo.identifier.uuidString

		let url = urlToScreen(photo: photo)

		let alert = UIAlertController(title: "Photo", message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Copy identifier", style: .default, handler: { _ in
			pasteboard?.string = identifier
		}))

		if let favoriteID = photo.favoriteID {
			alert.addAction(UIAlertAction(title: "Copy favoriteID", style: .default, handler: { _ in
				pasteboard?.string = String(favoriteID)
			}))
		}

		alert.addAction(UIAlertAction(title: "Copy app URL", style: .default, handler: { _ in
			pasteboard?.string = url
		}))

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		// You could do this manually without any issue
//		self.present(alert, animated: true, completion: nil)
		// Or use the stage
		stage.present(alert.sceneDescriptor).perform(animated: true)
	}

	func urlToScreen(photo: Photo) -> String {
		let identifier = photo.identifier.uuidString
		let categoryName = photo.category!

		var url = "storykit://"
		switch viewModel.context {
		case .categories:
			url += "categories/\(categoryName)/photos/\(identifier)"
		case .favorites:
			url += "favorites/\(photo.favoriteID!)"
		case .search:
			url += "search/\(identifier)"
		}
		return url
	}
}
