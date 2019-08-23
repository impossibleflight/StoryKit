//
//  StoryKit.swift
//  StoryKit
//
//  Created by John Clayton on 8/14/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import Foundation

/// All of your own view controllers *should* adhere to `SceneDescribing`, so we assert of we find one that doesn't. System controllers are not required to conform, though they may through extension. You can set this to false if you want to bypass this rule.
public var assertViewControllerNotSceneController = true

public var loggingEnabled = true
public func sk_log(_ format: String, _ args: CVarArg...) {
	if loggingEnabled {
		let _format = String(format: "[%@] - %@", String(describing: StoryKit.self), format)
		withVaList(args) { argsPointer in
			NSLogv(_format, argsPointer)
		}
	}
}

/// Calls `assert(::file:line:)` which stops execution when the condition is false in builds where it fires. In builds with optimization settings that disable asserts, prints the supplied message if the condition is false.
///
/// - SeeAlso: assert(::file:line:)
internal func assertOrPrint(_ condition: @autoclosure () -> Bool, _ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
	assert(condition)
	if !condition() {
		print(message())
	}
}

/// Calls `assertionFailure(:file:line:)` which will stop execution in builds where it fires. In builds with optimization settings that disable asserts, prints the supplied message.
///
/// - SeeAlso: assertionFailure(:file:line:)
internal func assertionFailureOrPrint(_ message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) {
	assertionFailure(message)
	print(message())
}

public class StoryKit {
	public static func register(storyboards descriptorTypes: SceneDescriptorConstructing.Type...) {
		for T in descriptorTypes {
			self.register(storyboard: T.self)
		}
	}

	public static func register(storyboard descriptorType: SceneDescriptorConstructing.Type) {
		storyboardDescriptorTypes.append(descriptorType)
	}

	public static func descriptor(forName name: String, identifier: String) -> SceneDescriptor? {
		for T in storyboardDescriptorTypes {
			if "\(T)" == name {
				return T.by(restorationIdentifier: identifier)
			}
		}
		return nil
	}

	public func descriptor(forName name: String, identifier: String) -> SceneDescriptor? {
		return (type(of: self)).descriptor(forName: name, identifier: identifier)
	}

	private static var storyboardDescriptorTypes = [SceneDescriptorConstructing.Type]()
}
