import SwiftUI
import AppUI
import Combine

@MainActor
protocol ProfileViewRouteDelegate: ReduxRouteDelegate {
    func pushDetail(_ userId: String)
    func pushEdit()
    func pushHomeDetail(_ id: String)
}

extension Coordinator: ProfileViewRouteDelegate {
    func pushDetail(_ userId: String) {
        router.push(\.profileDetail, userId)
    }

    func pushEdit() {
        router.push(\.profileEdit)
    }

    func pushHomeDetail(_ id: String) {
        global.push(.homeDetail, id)
    }
}

@MainActor @Observable
final class ProfileViewModel: ReduxViewModel {
    weak var routeDelegate: Coordinator?

    init(routeDelegate: Coordinator? = .shared) {
        self.routeDelegate = routeDelegate
    }
}

extension ProfileViewModel {
    enum ViewAction {
        case pushDetail(String)
        case pushEdit
        case pushHomeDetail(String)
    }

    func reduce(_ action: ViewAction) -> Effect? {
        switch action {
        case .pushDetail(let userId):
            routeDelegate?.pushDetail(userId)
        case .pushEdit:
            routeDelegate?.pushEdit()
        case .pushHomeDetail(let id):
            routeDelegate?.pushHomeDetail(id)
        }
        return nil
    }
}
