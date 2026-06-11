// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BaseKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "BaseFoundation",
            targets: ["BaseFoundation"]),
        .library(
            name: "BaseKit",
            targets: ["BaseKit"]),
        
    ],
    dependencies: [
        .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", branch: "master")
    ],
    targets: [
        .target(
            name: "BaseFoundation", dependencies: [
                .product(name: "SwifterSwiftFoundation", package: "SwifterSwift")
            ]),
        .target(
            name: "BaseKit",
            dependencies: [
                .target(name: "BaseFoundation"),
                .product(name: "SwifterSwiftNoIBInspectable", package: "SwifterSwift")
            ]),
    ]
)
