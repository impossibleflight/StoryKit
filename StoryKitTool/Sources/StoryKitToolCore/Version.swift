//
//  Version.swift
//  StoryKitToolCore
//
//  Created by John Clayton on 1/23/19.
//

import Foundation

public class Version {
	public static var version: String {
		let bundle = Bundle(for: self)
		let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
		return version
	}
	public static var bundleVersion: Int {
		let bundle = Bundle(for: self)
		let versionString = bundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
		return (try? Int(argument: versionString)) ?? 0
	}
}
