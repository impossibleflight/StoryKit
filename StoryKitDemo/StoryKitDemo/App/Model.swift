//
//  Model.swift
//  StoryKitDemo
//
//  Created by John Clayton on 10/15/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import Foundation
import StoryKit

class Category {
	let name: String
	private(set) var photos:[Photo]

	init(name: String, photos: [Photo] = []) {
		self.name = name
		self.photos = photos
	}

	func add(photo: inout Photo) {
		photos.append(photo)
		photo.category = self
	}
}

extension Category: Equatable {
	static func == (lhs: Category, rhs: Category) -> Bool {
		return lhs.name == rhs.name
	}
}

class Photo {
	private(set) var identifier: UUID
	var favoriteID: Int?
	private(set) var url: URL
	var tags: [String]
	weak var category: Category?
	var favorite: Bool {
		return favoriteID != nil
	}

	init(url: URL, tags: [String] = [], category: Category? = nil) {
		self.identifier = UUID()
		self.url = url
		self.tags = tags
		self.category = category
	}
}

extension Photo: Hashable {
	static func ==(lhs: Photo, rhs: Photo) -> Bool {
		return lhs.identifier == rhs.identifier
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(identifier)
	}
}

class Session: Condition {
	func observe(eventBlock: @escaping (Event) -> Void) {
		eventBlocks.append(eventBlock)
		next()
	}

	func login() {
		loggedIn = true
	}

	private var loggedIn: Bool = false {
		didSet {
			next()
		}
	}

	private var eventBlocks = [((Event)->Void)]()
	private func next() {
		let event = Event.next(loggedIn)
		for block in eventBlocks {
			block(event)
		}
	}
}
