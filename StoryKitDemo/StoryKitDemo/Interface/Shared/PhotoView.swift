//
//  PhotoView.swift
//  StoryKitDemo
//
//  Created by John Clayton on 11/19/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

import Bridge
import QuartzCore

class PlaceholderView: UIView {
	var animating: Bool = false

	func initialize() {
		isUserInteractionEnabled = false
	}

	func ready() {
		backgroundColor = .darkGray
		alpha = 0.0
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
		ready()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		ready()
	}

	func startAnimating(duration: TimeInterval = 5.0) {
		guard !animating else { return }
		animating = true
		let animation = CABasicAnimation(keyPath: "opacity")
		animation.toValue = 1.0
		animation.fillMode = CAMediaTimingFillMode.forwards
		animation.isRemovedOnCompletion = false
		animation.duration = duration
		animation.repeatCount = Float.greatestFiniteMagnitude
		animation.autoreverses = true
		layer.add(animation, forKey: "fade")
	}

	func stopAnimating() {
		guard animating else { return }
		animating = false
		layer.removeAllAnimations()
		alpha = 0.0
	}
}

class PhotoView: UIView {

	@IBOutlet var imageView: UIImageView!
	@IBOutlet var heartButton: UIButton!
	@IBOutlet var placeholderView: PlaceholderView!

	var photo: Photo! {
		didSet {
			placeholderView.startAnimating()
			imageView?.loadFromURL(photo.url) { [weak self] in
				self?.placeholderView.stopAnimating()
			}
			heartButton.isHidden = !photo.favorite
		}
	}

	func prepareForReuse() {
		imageView.loadFromURL(nil)
		placeholderView.stopAnimating()
		heartButton.isHidden = false
	}

	override func layoutSubviews() {
		super.layoutSubviews()
	}
}

extension UIImageView: ObjectAssociable {
	private struct AssociationKeys {
		static var loadImageTask = "loadImageTask"
	}

	private var loadImageTask: URLSessionTask? {
		get {
			return get(associatedObjectForKey: &AssociationKeys.loadImageTask)
		}
		set {
			loadImageTask?.cancel()
			set(associatedObject: newValue, forKey: &AssociationKeys.loadImageTask)
		}
	}

	func loadFromURL(_ url: URL?, completion: (()->Void)? = nil) {
		if let url = url {
			let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
				guard let r = response as? HTTPURLResponse,  r.statusCode == 200, error == nil else {
					print("Bad response: \(String(describing: response))")
					print("Loading random image instead ...")
					DispatchQueue.main.async {
						self?.loadFromURL(URL(string: "https://picsum.photos/300/300"), completion: completion)
					}
					return
				}
				guard let data = data, let image = UIImage(data: data) else {
					print("Cannot load image with data from URL \(url)")
					return
				}
				guard error == nil else {
					print("Got error fetching image for URL \(String(describing: error)) \(url)")
					return
				}
				DispatchQueue.main.async {
					self?.image = image
					if let completion = completion {
						completion()
					}
				}
			}
			self.loadImageTask = task
			task.resume()

		} else {
			self.loadImageTask = nil
			DispatchQueue.main.async {
				self.image = nil
				if let completion = completion {
					completion()
				}
			}
		}
	}
}

class PhotoViewReference: ViewReference<PhotoView> {}
