// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppUI",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppUI",
            targets: ["AppUI"]
        ),
    ],
    dependencies: [
        .package(path: "../../LocalPackages/SwiftUIRouter"),
        .package(path: "../../LocalPackages/BaseKit"),
        .package(path: "../../AppServices/AppFoundation"),
        .package(url: "https://github.com/mac-cain13/R.swift", from: "7.0.0"),
        .package(url: "https://github.com/DebugSwift/DebugSwift", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppUI",
            dependencies: [
                .product(name: "Coordinator", package: "SwiftUIRouter"),
                .product(name: "BaseKit", package: "BaseKit"),
                .product(name: "AppFoundation", package: "AppFoundation"),
                .product(name: "DebugSwift", package: "DebugSwift"),
                .product(name: "RswiftLibrary", package: "R.swift"),
            ],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "RswiftGeneratePublicResources", package: "R.swift")]
        ),
    ]
)
