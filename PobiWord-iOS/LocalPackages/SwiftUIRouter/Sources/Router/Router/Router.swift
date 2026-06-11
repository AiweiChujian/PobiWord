//
//  Router.swift
//
//
//  Created by Avery on 2024/9/3.
//

import Foundation
import SwiftUI
import Combine

public protocol Router: Routable {
    init()

    typealias Node = RouteNode

    var navigationNodes: [Node] { get set }

    var nodesPublisher: Published<[Node]>.Publisher { get }

    typealias Assistant = RouterAssistant<Self>

    var assistant: Assistant { get }
}

// MARK: -
public extension Router {
    static func root<Input>(_ route: KeyPath<Self, RoutePath<Self, Input>>, _ input: Input = ()) -> some View {
        let router = Self()
        let result = router.parse(route: route)
        let view = result.routePath.using(router: router, input: input)
        return NavigationController.new(
            Self.self,
            last: nil,
            router: router,
            rootTitle: result.title,
            rootView: view
        )
    }

    func getFirstRoute<Input>(route: KeyPath<Self, RoutePath<Self, Input>>) -> Node? {
        navigationNodes.first(where: {$0.routeValue == route.hashValue})
    }

    /// 根据路由和 Input 创建节点
    /// - Parameters:
    ///   - route: 节点路由
    ///   - input: 输入参数
    /// - Returns: 节点
    func node<Input>(for route: KeyPath<Self, RoutePath<Self, Input>>, _ input: Input = ()) -> Node {
        let result = parse(route: route)
        let view = result.routePath.using(router: self, input: input)
        return .init(title: result.title, routeValue: route.hashValue) {
            view
        }
    }
}

public extension Router {
    /// Push 节点
    /// - Parameters:
    ///   - route: 节点路由
    ///   - input: 传递给节点的参数
    func push<Input>(_ route: KeyPath<Self, RoutePath<Self, Input>>, _ input: Input = ()) {
        navigationNodes.append(node(for: route, input))
    }
    

    /// Pop 路由节点
    /// - Parameter count: pop 节点数量
    func pop(_ count: Int = 1) {
        let count = max(0, count)
        if count <= navigationNodes.count {
            navigationNodes.removeLast(count)
        } else {
            navigationNodes.removeAll()
        }
    }

    /// Pop 到指定节点(最近的一个)
    /// - Parameter route: 节点路由
    func pop<Input>(to route: KeyPath<Self, RoutePath<Self, Input>>) {
        let routeValue = route.hashValue
        guard let index = navigationNodes.lastIndex(where: {$0.routeValue == routeValue})
        else { return }
        navigationNodes = Array(navigationNodes[0...index])
    }

    /// Pop 到根节点
    func popToRoot() {
        navigationNodes.removeAll()
    }
}
