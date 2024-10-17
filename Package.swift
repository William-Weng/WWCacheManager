// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWCacheManager",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "WWCacheManager", targets: ["WWCacheManager"]),
    ],
    targets: [
        .target(name: "WWCacheManager"),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
