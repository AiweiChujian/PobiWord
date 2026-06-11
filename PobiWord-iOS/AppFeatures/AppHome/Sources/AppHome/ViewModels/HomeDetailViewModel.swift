import SwiftUI
import AppUI
import Combine

@MainActor
protocol HomeDetailViewRouteDelegate: ReduxRouteDelegate {
    func pushProfileDetail(_ id: String)
}

extension Coordinator: HomeDetailViewRouteDelegate {}

@MainActor @Observable
final class HomeDetailViewModel: ReduxViewModel {
    weak var routeDelegate: Coordinator?

    init(routeDelegate: Coordinator? = .shared) {
        self.routeDelegate = routeDelegate
    }
}

extension HomeDetailViewModel {
    enum ViewAction {
        case pushProfileDetail(String)
    }

    func reduce(_ action: ViewAction) -> Effect? {
        switch action {
        case .pushProfileDetail(let id):
            routeDelegate?.pushProfileDetail(id)
        }
        return nil
    }
}
