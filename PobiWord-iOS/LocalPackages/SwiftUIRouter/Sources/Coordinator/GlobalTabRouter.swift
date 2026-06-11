//
//  File 3.swift
//  SwiftUIRouter
//
//  Created by Avery on 2026/4/3.
//

import Foundation
import SwiftUI

public struct RouteTabContent<RouteTab: Hashable>: Identifiable {
    public let tab: RouteTab
    public let content: AnyView

    public var id: RouteTab { tab }

    public init(tab: RouteTab, content: AnyView) {
        self.tab = tab
        self.content = content
    }
}

public protocol GlobalTabRouter: GlobalRouter {
    associatedtype RouteTab: Hashable

    var selectedTab: RouteTab { get set }

    var tabs: [RouteTabContent<RouteTab>] { get set }
}

public extension GlobalTabRouter {
    func registerTab(_ tab: RouteTab, @ViewBuilder content: @escaping () -> some View) {
        guard !tabs.map({ $0.tab }).contains(tab) else {
            assertionFailure("Duplicate registration for tab: \(tab)")
            return
        }
        tabs.append(.init(tab: tab, content: .init(content())))
    }

    @ViewBuilder
    func tabView(for tab: RouteTabContent<RouteTab>) -> some View {
        tab.content.tag(tab.tab)
    }
}
