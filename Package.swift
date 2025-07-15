// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftMetronome",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftMetronome",
            targets: ["SwiftMetronome"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/AudioKit/AudioKit.git", from: "5.6.0"),
        .package(url: "https://github.com/AudioKit/AudioKitEX.git", from: "5.6.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftMetronome",
            dependencies: [
                .product(name: "AudioKit", package: "AudioKit"),
                .product(name: "AudioKitEX", package: "AudioKitEX")
            ],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "SwiftMetronomeTests",
            dependencies: ["SwiftMetronome"]
        ),
    ]
)
