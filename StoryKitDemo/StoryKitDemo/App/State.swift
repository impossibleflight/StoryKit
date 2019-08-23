//
//  State.swift
//  StoryKitDemo
//
//  Created by John Clayton on 10/17/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import Foundation

struct State {
	let session = Session()
	var categories = [Category]()
	init() {
		stub()
	}
}

//MARK: Derived attributes
extension State {
	var photos: [Photo] {
		return categories.reduce([Photo]()) { (result, category) in
			var photos = result
			photos += category.photos
			return photos
		}
	}
	var favorites: [Photo] {
		return photos.filter { $0.favorite }
	}

	var tags: [String] {
		return Array(photos.reduce(Set<String>()) { tags, photo in
			return tags.union(photo.tags)
		}).sorted()
	}

	var rankedTags: [String] {
		let rankedTags: [String] = photos
			.flatMap { $0.tags }
			.reduce([String:Int]()) { counts, tag in
				var newCounts = counts
				let count = (newCounts[tag] ?? 0) + 1
				newCounts[tag] = count
				return newCounts
			}
			.sorted { lpair, rpair in
				let (_,lvalue) = lpair
				let (_,rvalue) = rpair
				return lvalue > rvalue
			}
			.map { $0.0 }
		return rankedTags
	}
}

// MARK: - Finders
extension State {
	func category(named name: String) -> Category? {
		return categories.filter { $0.name.caseInsensitiveCompare(name) == .orderedSame }.first
	}

	func photo(withIdentifier identifier: UUID) -> Photo? {
		return photos.filter { $0.identifier == identifier }.first
	}

	func photos(forTag tag: String) -> [Photo] {
		return photos.filter { $0.tags.contains { tag.caseInsensitiveCompare($0) == .orderedSame } }
	}

	func favorite(withID favoriteID: Int) -> Photo? {
		return favorites.filter { $0.favoriteID == favoriteID }.first
	}

	func photos(forQuery query: String?) -> [Photo] {
		guard let query = query else { return photos }
		guard !query.isEmpty else { return photos }
		return photos.filter { (photo) -> Bool in
			if let category = photo.category, category.name.starts(with: query) { return true }
			let search = "*\(query)*"
			let predicate = NSPredicate(format: "SELF LIKE[cd] %@", search)
			let matchingTags = (photo.tags as NSArray).filtered(using: predicate)
			return !matchingTags.isEmpty
		}
	}
}

// MARK: - Mutators
extension State {
	func login() {
		session.login()
	}
	func add(category: Category) {
		fatalError("Unimplemented")
	}
	func add(categories: [Category]) {
		fatalError("Unimplemented")
	}
	func favorite(photo: Photo) {
		fatalError("Unimplemented")
	}
	func unfavorite(photo: Photo) {
		fatalError("Unimplemented")
	}
}


private let categoryNames = ["two", "futuristic", "fretful", "testy", "tired", "minor", "merciful", "unusual", "vengeful", "lamentable", "aback", "gratis", "hollow", "macho", "one", "greasy", "utopian", "sloppy", "cowardly", "adjoining", "holistic", "swanky", "wonderful", "well-groomed", "languid", "acoustic", "various", "damaged", "bright", "blushing", "four", "absent", "tightfisted", "entertaining", "quixotic", "elfin", "fancy", "efficacious", "heavenly", "amusing", "grandiose", "lean", "cynical", "huge", "polite", "tough", "successful", "ashamed", "loutish", "towering", "gentle", "handsomely", "measly", "enthusiastic", "jolly", "rightful", "tested", "famous", "miniature", "wacky", "juvenile", "incredible", "easy", "clumsy", "quizzical", "quaint", "plausible", "instinctive", "helpless", "amused", "white", "colossal", "foolish", "spotty", "hesitant", "terrific", "friendly", "handy", "slim", "feigned", "black-and-white", "true", "rebel", "fearless", "absurd", "standing", "far", "fabulous", "dry", "better", "fixed", "light", "overt", "obnoxious", "irate", "cruel", "lazy", "waggish", "devilish", "venomous", "truculent", "axiomatic", "tall", "demonic", "zealous", "chief", "fortunate", "economic", "handsome", "macabre", "teeny-tiny", "little", "uptight", "stupendous", "meek", "beautiful", "lackadaisical", "selfish", "male", "curved", "idiotic", "plain", "endurable", "rabid", "debonair", "cute", "subsequent", "milky", "eminent", "snotty", "black", "productive", "redundant", "glossy", "nostalgic", "sudden", "oafish", "humdrum", "temporary", "average", "innate", "highfalutin", "worried", "sore", "fat", "forgetful", "solid", "heavy", "dynamic", "thick", "unsightly", "cautious", "unhealthy", "vagabond", "same", "parsimonious", "bustling", "pricey", "pathetic", "uncovered", "habitual", "unkempt", "lonely", "violet", "limping", "evasive", "bloody", "sore", "defiant", "caring", "eight", "orange", "keen", "graceful", "wasteful", "tacky", "imperfect", "able", "massive", "undesirable", "smiling", "tidy", "unnatural", "magical", "tricky", "old-fashioned", "private", "inexpensive", "fuzzy", "cluttered", "juicy", "well-to-do", "clean", "spiteful", "homely", "bashful", "energetic", "unequaled", "high", "bent"]

private let tagNames = ["strong", "dress", "roasted", "lumpy", "stain", "unite", "juice", "scissors", "invite", "terrific", "trees", "lacking", "worm", "lighten", "uninterested", "tiny", "berry", "fresh", "lively", "untidy", "calm", "chin", "jittery", "abusive", "sticks", "huge", "pet", "uneven", "skate", "endurable", "name", "basket", "gold", "fearless", "governor", "absorbing", "lie", "jail", "copy", "fuzzy", "past", "apparel", "large", "fold", "fry", "meal", "train", "lunchroom", "slow", "fowl", "polish", "irate", "scale", "cry", "rod", "afraid", "wealthy", "right", "accept", "hope", "children", "pretty", "tense", "curtain", "share", "tongue", "notebook", "calculating", "spoil", "cushion", "end", "division", "clap", "basin", "ethereal", "difficult", "trousers", "tickle", "callous", "parched", "meddle", "close", "grandfather", "illustrious", "abnormal", "painstaking", "grumpy", "recess", "first", "sedate", "number", "turkey", "ashamed", "wash", "shrill", "fly", "bite", "behave", "care", "inject", "taboo", "hollow", "blush", "dogs", "obtain", "accidental", "old-fashioned", "sneeze", "fool", "stamp", "nonchalant", "flame", "haircut", "fearful", "clear", "middle", "fragile", "drown", "seat", "polite", "authority", "cool", "perform", "pink", "stretch", "different", "permit", "design", "guard", "sleepy", "scarf", "desk", "believe", "depend", "flavor", "rock", "wood", "border", "motion", "stop", "defeated", "cup", "imported", "near", "descriptive", "eager", "dare", "plants", "plug", "twig", "shrug", "outstanding", "jolly", "nosy", "nostalgic", "unknown", "produce", "part", "knotty", "vest", "wry", "far-flung", "square", "shiny", "example", "married", "glorious", "rhetorical", "dead", "agreement", "nest", "jog", "addition", "foolish", "ray", "abounding", "tightfisted", "rhyme", "empty", "addicted", "attract", "amused", "ubiquitous", "flower", "story", "rule", "pinch", "beautiful", "wide-eyed", "normal", "fierce", "ultra", "peace", "kick", "impress", "dog", "coach", "well-off", "lake", "trail"]

extension State {
	mutating func stub() {
		var categories = [Category]()
		var possibleNames = categoryNames
		for i in 0..<25 {
			possibleNames.shuffle()
			let category = Category(name: possibleNames.popLast()!.capitalized)
			for j in 1...25 {
				let tags = (0..<5).map { _ in return tagNames.randomElement()!.capitalized }
				let id = (0..<1084).randomElement() ?? 0
				var photo = Photo(url: URL(string: "https://picsum.photos/300/300?image=\(id)")!, tags: tags)
				if [true, false].randomElement()! {
					photo.favoriteID = (i*25)+j
				}
				category.add(photo: &photo)
			}
			categories.append(category)
		}
		self.categories = categories
	}
}

