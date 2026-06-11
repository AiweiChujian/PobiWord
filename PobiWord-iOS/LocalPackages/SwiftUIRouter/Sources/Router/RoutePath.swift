//
//  RoutePath.swift
//
//
//  Created by Avery on 2024/9/3.
//

import Foundation
import SwiftUI

public struct RoutePath<R: Routable, Input>: @unchecked Sendable {
    public let title: String?

    let closure: ((R) -> ((Input) -> AnyView))

    public func using(router: R, input: Input) -> AnyView {
        closure(router)(input)
    }
}

@propertyWrapper
public class RoutePathWrapper<T: Routable, Input> {

    public var wrappedValue: RoutePath<T, Input>

    init(standard: RoutePath<T, Input>) {
        self.wrappedValue = standard
    }
}

extension RoutePathWrapper {
    public convenience init<ViewOutput: View>(wrappedValue: @escaping ((T) -> ((Input) -> ViewOutput)), _ title: String? = nil) {
        self.init(standard: RoutePath(title: title, closure: { router in
            return { input in
                let target = wrappedValue(router)(input)
                    .environmentObject(router) // 将 Router 注入为环境对象
                return AnyView(target)
            }
        }))
    }
}

extension RoutePathWrapper where Input == Void {
    public convenience init<ViewOutput: View>(wrappedValue: @escaping ((T) -> (() -> ViewOutput)), _ title: String? = nil) {
        self.init(standard: RoutePath(title: title, closure: { router in
            return { _ in
                let target = wrappedValue(router)()
                    .environmentObject(router) // 将 Router 注入为环境对象
                return AnyView(target)
            }
        }))
    }
}
