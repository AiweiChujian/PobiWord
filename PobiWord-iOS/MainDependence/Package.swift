// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

enum PackageDependencies: CaseIterable {
    case appHome
    case appProfile
    
    var dependency: PackageDescription.Package.Dependency {
        switch self {
        case .appHome:
            return .package(path: "../AppFeatures/AppHome")
        case .appProfile:
            return .package(path: "../AppFeatures/AppProfile")
        }
    }
}

/// App Target 依赖的 Product
enum AppDependence: CaseIterable {
    case appHome
    case appProfile

    var dependency: PackageDescription.Target.Dependency {
        switch self {
        case .appHome:
            return .product(name: "AppHome", package: "AppHome")
        case .appProfile:
            return .product(name: "AppProfile", package: "AppProfile")
        }
    }
}


let package = Package(
    name: "MainDependence",
    platforms: [.iOS(.v17),],
    products: [
        .library(
            name: "MainDependence",
            type: .static,
            targets: ["MainDependence"]),
    ],
    dependencies: PackageDependencies.allCases.map { $0.dependency },
    targets: [
        .target(
            name: "MainDependence",
            dependencies: AppDependence.allCases.map { $0.dependency }
        ),
    ]
)
