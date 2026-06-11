// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppNetwork",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppNetwork",
            targets: ["AppNetwork"]),
    ],
    dependencies: [
        .package(path: "../../AppData"),
        .package(path: "../AppLog"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppNetwork",
            dependencies: [
                .product(name: "AppData", package: "AppData"),
                .product(name: "AppLog", package: "AppLog"),
                .product(name: "Alamofire", package: "Alamofire"),
            ]),

    ]
)
