//
//  FavoritesViewController.swift
//  StoryKitDemo
//
//  Created by John Clayton on 9/28/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit


class FavoritesViewController: UICollectionViewController {

	struct ViewModel {
		var favorites: [Photo] {
			return Container.instance.state.favorites
		}
	}

	var viewModel = ViewModel()
	private let cellIdentifier = "PhotoCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UINib(nibName: String(describing: PhotoCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
		let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
		let width = self.view.bounds.size.width
		let itemSpacing = flowLayout.minimumInteritemSpacing
		let layoutWidth = Float(width-(itemSpacing*4.0))
		let itemWidth = CGFloat(floorf(layoutWidth/3.0))
		flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.favorites.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PhotoCollectionViewCell else {
			fatalError("Failed to dequeue cell as \(PhotoCollectionViewCell.self)")
		}
    
		let photo = viewModel.favorites[indexPath.item]
		cell.photoView.photo = photo
		return cell
    }

    // MARK: UICollectionViewDelegate

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let photo = viewModel.favorites[indexPath.item]
		stage.push(Favorites.favorite(favoriteID: photo.favoriteID!)).perform()
	}
}
