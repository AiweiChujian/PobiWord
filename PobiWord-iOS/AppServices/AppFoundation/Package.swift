// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppFoundation",
    platforms: [
      .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppFoundation",
            targets: ["AppFoundation"]),
    ],
    dependencies: [
        .package(path: "../../AppData"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "2.1.1")),
        .package(url: "https://github.com/apple/swift-log", from: "1.6.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppFoundation",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "AppData", package: "AppData"),
                .product(name: "SwiftyBeaver", package: "SwiftyBeaver"),
                .product(name: "Alamofire", package: "Alamofire"),
            ]
        ),

    ]
)
