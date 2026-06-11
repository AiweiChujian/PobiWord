import AppUI

@MainActor
public final class Router: ExportableRouter {
    public typealias RouteKey = AppRouteKey

    public let appWindow: UIWindow

    public init(appWindow: UIWindow) {
        self.appWindow = appWindow
    }

    @Route var homeDetail = makeHomeDetailView

    public var exportedPaths: [AppRouteKey: ExportableRoutePath] {
        [.homeDetail: homeDetail]
    }
}

extension Router {
    func makeHomeDetailView(id: String) -> some View {
        HomeDetailView(id: id)
    }
}
