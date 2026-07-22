// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "WordPlanService",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "WordPlanService",
            targets: ["WordPlanService"]
        ),
    ],
    dependencies: [
        .package(path: "../AppFoundation"),
    ],
    targets: [
        .target(
            name: "WordPlanService",
            dependencies: [
                .product(name: "AppFoundation", package: "AppFoundation"),
            ],
            swiftSettings: [
                .defaultIsolation(MainActor.self),
            ]
        ),
        .testTarget(
            name: "WordPlanServiceTests",
            dependencies: ["WordPlanService"],
            swiftSettings: [
                .defaultIsolation(MainActor.self),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
