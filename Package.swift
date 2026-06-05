// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWCacheManager",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "WWCacheManager", targets: ["WWCacheManager"]),
    ],
    targets: [
        .target(name: "WWCacheManager", resources: [.copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
