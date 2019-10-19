// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DocumentIndexer",
    platforms: [
        .macOS("10.12")
    ],
    products: [
        .library(
            name: "DocumentIndexer",
            targets: ["DocumentIndexer"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "DocumentIndexer"),
        .testTarget(
            name: "DocumentIndexerTests",
            dependencies: ["DocumentIndexer"]),
    ]
)
