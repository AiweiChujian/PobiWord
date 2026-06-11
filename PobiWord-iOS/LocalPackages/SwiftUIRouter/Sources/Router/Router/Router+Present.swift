//
//  Router+Present.swift
//  MVVMRedux
//
//  Created by Avery on 2026/2/10.
//

import Foundation
import SwiftUI

// MARK: - Present
public extension Router {
    /// Present Sheet
    /// - Parameters:
    ///   - route: 节点路由
    ///   - input: 输入参数
    func present<Input>(sheet route: KeyPath<Self, RoutePath<Self, Input>>, _ input: Input = (), detents: Set<PresentationDetent> = [.large]) {
        let result = parse(route: route)
        let view = result.routePath.using(router: self, input: input)
        assistant.presentSheet(.init(detents: detents, sheetBuilder: { view }), sheetTitle: result.title)
    }
    

    /// Present Sheet
    /// - Parameters:
    ///   - route: 节点路由
    ///   - input: 输入参数
    func present<Input>(cover route: KeyPath<Self, RoutePath<Self, Input>>, _ input: Input = (), onDismiss: (() -> Void)? = nil) {
        let result = parse(route: route)
        let view = result.routePath.using(router: self, input: input)
        assistant.presentCover(.init(screenCoverBuilder: { view }, onDismiss: onDismiss), coverTitle: result.title)
    }
    

    /// Dismiss Sheet
    func dismiss() {
        assistant.dismiss()
    }

    /// Dismiss 当前路由器
    func dismissRouter() {
        last?.dismiss()
    }
}
