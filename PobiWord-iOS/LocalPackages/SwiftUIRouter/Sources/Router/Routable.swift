//
//  Routable.swift
//  MVVMRedux
//
//  Created by Avery on 2026/2/10.
//

import Foundation
@_exported import SwiftUI
@_exported import Combine

@MainActor
public protocol Routable: ObservableObject {
    typealias Root = RoutePathWrapper

    typealias Route = RoutePathWrapper

    func push<Input>(_ route: KeyPath<Self, RoutePath<Self, Input>>, _ input: Input)
    
    func pop(_ count: Int)
    
    func popToRoot()
}

public extension Routable {
    func parse<Input>(route: KeyPath<Self, RoutePath<Self, Input>>) -> (routePath: RoutePath<Self, Input>, title: String) {
        let routePath = self[keyPath: route]
        let title = routePath.title ?? "\(route)".trimmingCharacters(in: .init(charactersIn: "\\"))
        return (routePath, title)
    }
    
    func pop() { pop(1) }
}
