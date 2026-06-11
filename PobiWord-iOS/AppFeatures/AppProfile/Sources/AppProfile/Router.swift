import AppUI

@MainActor
public final class Router: ExportableRouter {
    public typealias RouteKey = AppRouteKey

    public let appWindow: UIWindow

    public init(appWindow: UIWindow) {
        self.appWindow = appWindow
    }

    @Route var profileDetail = makeProfileDetailView
    @Route var profileEdit = makeProfileEditView

    public var exportedPaths: [AppRouteKey: ExportableRoutePath] {
        [
            .profileDetail: profileDetail,
            .profileEdit: profileEdit,
        ]
    }
}

extension Router {
    func makeProfileDetailView(userId: String) -> some View {
        ProfileDetailView(userId: userId)
    }

    func makeProfileEditView() -> some View {
        ProfileEditView()
    }
}
