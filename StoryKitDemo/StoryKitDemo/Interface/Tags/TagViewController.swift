//
//  TagViewController.swift
//  StoryKitDemo
//
//  Created by John Clayton on 12/30/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

private let cellIdentifier = "PhotoCell"

class TagViewController: UICollectionViewController {
	struct ViewModel {
		var tag: String
		init(tag: String) {
			self.tag = tag
		}

		var photos: [Photo] {
			return Container.instance.state.photos(forQuery: tag)
		}
	}

	var viewModel: ViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = viewModel.tag

		collectionView!.register(UINib(nibName: String(describing: PhotoCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }


    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PhotoCollectionViewCell else {
			fatalError("Failed to dequeue cell as \(PhotoCollectionViewCell.self)")
		}
		let photo = viewModel.photos[indexPath.item]
		cell.photoView.photo = photo
		return cell
    }

	@IBAction func unwindAction(_ sender: Any) {
		if let presenter = self.presentingViewController {
			stage.unwind(to: presenter.sceneDescriptor).perform(animated: true)
		}
	}
}
