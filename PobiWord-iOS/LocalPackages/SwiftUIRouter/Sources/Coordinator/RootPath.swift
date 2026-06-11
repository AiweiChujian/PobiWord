//
//  File.swift
//  SwiftUIRouter
//
//  Created by Avery on 2026/4/3.
//

import Foundation
import SwiftUI

public struct RootPath<R: GlobalRouter, Input>: @unchecked Sendable {
    public let title: String?

    let closure: ((R) -> ((Input) -> AnyView))

    public func using(router: R, input: Input) -> AnyView {
        closure(router)(input)
    }
}

@propertyWrapper
public class RootPathWrapper<T: GlobalRouter, Input> {

    public var wrappedValue: RootPath<T, Input>

    init(standard: RootPath<T, Input>) {
        self.wrappedValue = standard
    }
}

extension RootPathWrapper {
    public convenience init<ViewOutput: View>(wrappedValue: @escaping ((T) -> ((Input) -> ViewOutput)), _ title: String? = nil) {
        self.init(standard: RootPath(title: title, closure: { router in
            return { input in
                let target = wrappedValue(router)(input)
                return AnyView(target)
            }
        }))
    }
}

extension RootPathWrapper where Input == Void {
    public convenience init<ViewOutput: View>(wrappedValue: @escaping ((T) -> (() -> ViewOutput)), _ title: String? = nil) {
        self.init(standard: RootPath(title: title, closure: { router in
            return { _ in
                let target = wrappedValue(router)()
                return AnyView(target)
            }
        }))
    }
}
