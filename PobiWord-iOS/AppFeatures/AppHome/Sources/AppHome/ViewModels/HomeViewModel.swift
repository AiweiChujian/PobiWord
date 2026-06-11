import SwiftUI
import AppUI
import Combine

@MainActor
protocol HomeViewRouteDelegate: ReduxRouteDelegate {
    func pushDetail(_ id: String)
    func pushProfileDetail(_ id: String)
}

extension Coordinator: HomeViewRouteDelegate {
    func pushDetail(_ id: String) {
        router.push(\.homeDetail, id)
    }

    func pushProfileDetail(_ id: String) {
        global.push(.profileDetail, id)
    }
}

@MainActor @Observable
final class HomeViewModel: ReduxViewModel {
    weak var routeDelegate: Coordinator?

    init(routeDelegate: Coordinator? = .shared) {
        self.routeDelegate = routeDelegate
    }
}

extension HomeViewModel {
    enum ViewAction {
        case pushDetail(String)
        case pushProfileDetail(String)
    }

    func reduce(_ action: ViewAction) -> Effect? {
        switch action {
        case .pushDetail(let id):
            routeDelegate?.pushDetail(id)
        case .pushProfileDetail(let id):
            routeDelegate?.pushProfileDetail(id)
        }
        return nil
    }
}
