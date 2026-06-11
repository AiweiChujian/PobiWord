import SwiftUI
import AppUI
import Combine

@MainActor
protocol ProfileDetailViewRouteDelegate: ReduxRouteDelegate {
    func pushEdit()
    func pushHomeDetail(_ id: String)
}

extension Coordinator: ProfileDetailViewRouteDelegate {}

@MainActor @Observable
final class ProfileDetailViewModel: ReduxViewModel {
    weak var routeDelegate: Coordinator?

    init(routeDelegate: Coordinator? = .shared) {
        self.routeDelegate = routeDelegate
    }
}

extension ProfileDetailViewModel {
    enum ViewAction {
        case pushEdit
        case pushHomeDetail(String)
    }

    func reduce(_ action: ViewAction) -> Effect? {
        switch action {
        case .pushEdit:
            routeDelegate?.pushEdit()
        case .pushHomeDetail(let id):
            routeDelegate?.pushHomeDetail(id)
        }
        return nil
    }
}
