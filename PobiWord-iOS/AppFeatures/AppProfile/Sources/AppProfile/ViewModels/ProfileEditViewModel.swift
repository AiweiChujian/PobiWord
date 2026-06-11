import SwiftUI
import AppUI
import Combine

@MainActor
protocol ProfileEditViewRouteDelegate: ReduxRouteDelegate {

}

extension Coordinator: ProfileEditViewRouteDelegate {}

@MainActor @Observable
final class ProfileEditViewModel: ReduxViewModel {
    weak var routeDelegate: Coordinator?

    init(routeDelegate: Coordinator? = .shared) {
        self.routeDelegate = routeDelegate
    }
}

extension ProfileEditViewModel {
    enum ViewAction {

    }

    func reduce(_ action: ViewAction) -> Effect? {

    }
}
