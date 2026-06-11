// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIRouter",
    platforms: [
      .iOS(.v17),
    ],
    products: [
        .library(
            name: "Router",
            targets: ["Router"]
        ),
        .library(
            name: "UIRouter",
            targets: ["UIRouter"]
        ),
        .library(
            name: "Coordinator",
            targets: ["Coordinator"]
        ),
    ],
    targets: [
        .target(
            name: "Router"
        ),
        .target(
            name: "UIRouter",
            dependencies: [.target(name: "Router")]
        ),
        .target(
            name: "Coordinator",
            dependencies: [.target(name: "UIRouter")]
        ),
    ]
)
