//
//  RouterNode.swift
//  MVVMRedux
//
//  Created by Avery on 2026/2/10.
//

import Foundation
import SwiftUI

public struct RouteNode {
    public var title: String

    public var routeValue: Int

    public var destinationBuilder: () -> AnyView
}

extension RouteNode: Hashable {
    public static func == (lhs: RouteNode, rhs: RouteNode) -> Bool {
        lhs.routeValue == rhs.routeValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(routeValue)
    }
}
