// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "WordPlan",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "WordPlan",
            targets: ["WordPlan"]
        ),
    ],
    dependencies: [
        .package(path: "../../AppServices/WordPlanService"),
    ],
    targets: [
        .target(
            name: "WordPlan",
            dependencies: [
                .product(name: "WordPlanService", package: "WordPlanService"),
            ],
            swiftSettings: [
                .defaultIsolation(MainActor.self),
            ]
        ),
        .testTarget(
            name: "WordPlanTests",
            dependencies: ["WordPlan"],
            swiftSettings: [
                .defaultIsolation(MainActor.self),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
