import Foundation
import SwiftUI

public enum AppTab: Hashable {
    case home
    case profile
}

@MainActor
public final class AppRouter: ObservableObject, GlobalTabRouter {
    public typealias RouteKey = AppRouteKey
    public typealias RootParams = Void
    public typealias RouteTab = AppTab

    public let appWindow: UIWindow
    public var registeredRoutes: [AppRouteKey: ExportedRoute] = [:]
    @Published public var selectedTab: AppTab = .home
    public var tabs: [RouteTabContent<AppTab>] = []

    @Root public var rootView = makeRootView

    public required init(appWindow: UIWindow) {
        self.appWindow = appWindow
    }
}

extension AppRouter {
    func makeRootView() -> some View {
        RootTabView()
            .environmentObject(self)
    }
}
