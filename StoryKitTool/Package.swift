// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StoryKitTool",
	products: [
		.library(name: "StoryKitToolCore", targets: ["StoryKitToolCore"]),
		.executable(name: "storykit", targets: ["StoryKitTool"]),
	],
    dependencies: [
		.package(url: "https://github.com/apple/swift-package-manager.git", from: "0.1.0"),
		.package(url: "https://github.com/stencilproject/Stencil.git", from: "0.13.0")
    ],
    targets: [
		.target(
			name: "StoryKitToolCore",
			dependencies: ["Utility", "Stencil"]),
		.testTarget(
			name: "StoryKitToolCoreTests",
			dependencies: ["StoryKitToolCore"]),
        .target(
            name: "StoryKitTool",
			dependencies: ["StoryKitToolCore"]),
        .testTarget(
            name: "StoryKitToolTests",
            dependencies: ["StoryKitTool"]),
    ]
)
