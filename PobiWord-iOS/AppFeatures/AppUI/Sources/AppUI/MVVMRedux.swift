//
//  MVVMRedux.swift
//  MVVMRedux
//
//  Created by Aiwei on 2024/7/30.
//

import Foundation
import SwiftUI

// MARK: - CommandEffect
@MainActor
open class CommandEffect<T: ReduxViewModel> {
    public weak var viewModel: T?
    
    public required init(_ viewModel: T) {
        self.viewModel = viewModel
    }

    @MainActor
    open func execute() async -> T.ViewAction? {
        assertionFailure("Sub class should implement `execute()`")
        return nil
    }
}

// MARK: - ReduxRouteDelegate
public protocol ReduxRouteDelegate: AnyObject {}

// MARK: - ReduxViewModel
@MainActor
public protocol ReduxViewModel: ObservableObject, Observable {
    associatedtype RouteDelegate: ReduxRouteDelegate

    var routeDelegate: RouteDelegate? { get }

    associatedtype ViewAction

    func send(_ action: ViewAction)

    typealias Effect = CommandEffect<Self>

    func reduce(_ action: ViewAction) -> Effect?
}

public extension ReduxViewModel {
    @MainActor
    func send(_ action: ViewAction) {
        guard let effect = reduce(action) else { return }
        Task {[weak self] in
            guard let nextAction = await effect.execute() else {
                return
            }
            self?.send(nextAction)
        }
    }

    var routeDelegate: RouteDelegate? { nil }
}

// MARK: - ReduxView
@MainActor
public protocol ReduxView: View {
    associatedtype ViewModel: ReduxViewModel

    var viewModel: ViewModel { get }

    associatedtype ReduxBody: View

    @ViewBuilder
    var reduxBody: ReduxBody { get }
}

public extension ReduxView {
    @ViewBuilder @MainActor
    var body: some View {
        reduxBody.environmentObject(viewModel)
    }
    
    var routeDelegate: ViewModel.RouteDelegate? {
        viewModel.routeDelegate
    }
}
