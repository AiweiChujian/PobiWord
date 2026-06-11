// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppData",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppData",
            type: .static,
            targets: ["AppData"]),
        .library(
            name: "CoreTypes",
            type: .static,
            targets: ["CoreTypes"]),
    ],
    dependencies: [
        .package(path: "../LocalPackages/BaseKit")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CoreTypes",
            dependencies: [
                .product(name: "BaseFoundation", package: "BaseKit")
            ]
        ),
        .target(
            name: "AppData",
            dependencies: [
                .target(name: "CoreTypes")
            ]
        ),
    ]
)
