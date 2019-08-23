//
//  main.swift
//  Basic
//
//  Created by John Clayton on 1/14/19.
//  Copyright © 2019 Impossible Flight, LLC. All rights reserved.
//

import Foundation
import StoryKitToolCore

var tool = StoryKitTool(
	usage: "<command> <options>",
	overview: "StoryKit analyzes storyboards and outputs swift source code that represents the storyboards for use with the StoryKit framework."
)

tool.register(command: VersionCommand.self)
tool.register(command: InitCommand.self)
tool.register(command: UpdateCommand.self)

do {
	try tool.run(arguments: Array(CommandLine.arguments.dropFirst()))
} catch let error as FatalError {
	print(error)
	exit(error.code)
}
