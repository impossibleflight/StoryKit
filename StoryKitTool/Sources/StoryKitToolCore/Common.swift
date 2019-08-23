//
//  Common.swift
//  Basic
//
//  Created by John Clayton on 1/23/19.
//

import Foundation

infix operator +
extension Dictionary {
	static func +(lhs: Dictionary, rhs: Dictionary) -> Dictionary {
		return lhs.merging(rhs){(_,new) in new}
	}
}

extension String {
	var range: Range<String.Index> {
		return self.range(of: self)!
	}
}

extension NSRange {
	init(in string: String) {
		self.init(string.range, in: string)
	}
}

