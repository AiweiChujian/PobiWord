import AppUI

@MainActor
public final class Coordinator: FeatureCoordinator, ReduxRouteDelegate {
    public static var shared: Coordinator!

    public let global: AppRouter
    public let router: Router

    private init(global: AppRouter) {
        self.global = global
        self.router = Router(appWindow: global.appWindow)
    }

    public static func registerRoutes(in global: AppRouter) {
        let coordinator = Coordinator(global: global)
        shared = coordinator

        global.register(coordinator.router)

        global.registerTab(.home) {
            HomeView()
                .tabItem {
                    Label {
                        Text("Home")
                    } icon: {
                        Image(systemName: "house")
                            .renderingMode(.template)
                    }
                }
        }
    }
}
