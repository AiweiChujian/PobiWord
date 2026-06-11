import AppUI

@MainActor
public final class Coordinator: FeatureCoordinator, ReduxRouteDelegate {
    nonisolated(unsafe) public static var shared: Coordinator!

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

        global.registerTab(.profile) {
            ProfileView()
                .tabItem {
                    Label {
                        Text("Profile")
                    } icon: {
                        Image(systemName: "person.crop.circle.fill")
                            .renderingMode(.template)
                    }
                }
        }
    }
}
