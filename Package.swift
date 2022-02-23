// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SyncTokamak",
    platforms: [.macOS(.v11), .iOS(.v14), .watchOS(.v6), .tvOS(.v14)],
    products: [
        .library(name: "SyncTokamak",
                 targets: ["SyncTokamak"]),
    ],
    dependencies: [
        .package(name: "Sync", url: "https://github.com/nerdsupremacist/Sync.git", from: "1.0.0"),
        .package(name: "Tokamak", url: "https://github.com/TokamakUI/Tokamak", from: "0.9.1"),
    ],
    targets: [
        .target(name: "SyncTokamak",
                dependencies: [
                    "Sync",
                    .product(name: "TokamakDOM", package: "Tokamak", condition: .when(platforms: [.wasi]))
                ]),
        .testTarget(name: "SyncTokamakTests",
                    dependencies: ["SyncTokamak"]),
    ]
)
