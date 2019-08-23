//
//  Errors.swift
//  StoryKitToolCore
//
//  Created by John Clayton on 1/21/19.
//

import Foundation

public enum ErrorCode: Int32 {
	case argumentError = 1
	case executionError
	case initError
	case updateError
	case storyboardLoadingError
	case storyboardParsingError
	case unknownError = 99
}

public enum FatalError: Swift.Error, CustomStringConvertible {
	case withUnderlying(Swift.Error, ErrorCode)

	public var description: String {
		if case let .withUnderlying(error,code) = self {
			return "Fatal error: \(error) (code = \(code))"
		}
		preconditionFailure()
	}

	public var code: Int32 {
		if case let .withUnderlying(_,code) = self {
			return code.rawValue
		}
		preconditionFailure()
	}
}
