//
//  CategoryPhotosViewController.swift
//  StoryKitDemo
//
//  Created by John Clayton on 9/28/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

private let cellIdentifier = "PhotoCell"
private let headerIdentifier = "EmptyHeader"

class CategoryPhotosViewController: UICollectionViewController {
	struct ViewModel {
		var category: Category? = nil
		init(name: String) {
			category = Container.instance.state.category(named: name)
		}
	}

	var viewModel: ViewModel!

	override func viewDidLoad() {
		super.viewDidLoad()
		collectionView!.register(UINib(nibName: String(describing: PhotoCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
		guard let category = viewModel.category else {
			title = "Category"
			collectionView!.isScrollEnabled = false
			return
		}
		title = category.name
	}

	// MARK: UICollectionViewDataSource

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let category = viewModel.category else { return 0 }
		return category.photos.count
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let category = viewModel.category else {
			fatalError("You can not be here")
		}
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PhotoCollectionViewCell else {
			fatalError("Failed to dequeue cell as \(PhotoCollectionViewCell.self)")
		}
		let photo = category.photos[indexPath.item]
		cell.photoView.photo = photo
		return cell
	}

	// MARK: UICollectionViewDelegate

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let category = viewModel.category else { return }
		let photo = category.photos[indexPath.item]
		stage.push(Photos.photo(identifier: photo.identifier.uuidString)).perform()
	}

	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		if kind == UICollectionView.elementKindSectionHeader {
			return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath)
		}
		fatalError("You can't be here")
	}
	
}

extension CategoryPhotosViewController: UICollectionViewDelegateFlowLayout {
	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		guard viewModel.category != nil else {
			return collectionView.bounds.size
		}
		return CGSize.zero
	}
}
