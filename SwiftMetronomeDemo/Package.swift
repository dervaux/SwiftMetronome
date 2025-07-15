// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SwiftMetronomeDemo",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    dependencies: [
        .package(path: "../")
    ]
)
