// swift-tools-version:5.3
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
            name: "DocumentIndexer",
            dependencies: [],
            resources: [
                // Source URL: https://github.com/stopwords-iso/stopwords-iso/blob/master/stopwords-iso.json
                .copy("Resources/stopwords-iso.json")
            ]),
        .testTarget(
            name: "DocumentIndexerTests",
            dependencies: ["DocumentIndexer"],
            resources: [.copy("Resources")]),
    ]
)
