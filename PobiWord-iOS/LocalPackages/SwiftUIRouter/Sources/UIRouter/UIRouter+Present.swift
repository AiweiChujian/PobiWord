//
//  UIRouter+Present.swift
//  MVVMRedux
//
//  Created by Avery on 2025/6/30.
//

import Foundation
import SwiftUI
import Router

// MARK: - Dismiss
public extension UIRouter {
    func dismiss(animated: Bool = true, completion: PresentCompletion? = nil) {
        navigator.dismiss(animated: animated, completion: completion)
    }
}

// MARK: - Present
public extension UIRouter {
    func present<Input>(
        _ route: KeyPath<Self, RoutePath<Self, Input>>,
        _ input: Input = (),
        animated: Bool = true,
        transitioningDelegate: UIViewControllerTransitioningDelegate? = nil,
        setup: PresentSetup = {_ in},
        completion: PresentCompletion? = nil
    ) {
        let viewController = makeViewController(for: route, input)
        present(
            viewController: viewController,
            animated: animated,
            transitioningDelegate: transitioningDelegate,
            setup: setup,
            completion: completion
        )
    }
    
    func presentNavigable<Input>(
        _ route: KeyPath<Self, RoutePath<Self, Input>>,
        _ input: Input = (),
        animated: Bool = true,
        transitioningDelegate: UIViewControllerTransitioningDelegate? = nil,
        setup: PresentSetup = {_ in},
        completion: PresentCompletion? = nil
    ) {
        let viewController = makeViewController(for: route, input)
        presentNavigation(
            viewController,
            animated: animated,
            transitioningDelegate: transitioningDelegate,
            setup: setup,
            completion: completion
        )
    }
}

// MARK: - Present Sheet
public extension UIRouter {
    func presentSheet<Input>(
        _ route: KeyPath<Self, RoutePath<Self, Input>>,
        _ input: Input = (),
        animated: Bool = true,
        setup: PresentSetup = {_ in},
        completion: PresentCompletion? = nil
    ) {
        let viewController = makeViewController(for: route, input)
        present(
            viewController: viewController,
            animated: animated,
            setup: { presented in
            presented.modalPresentationStyle = .pageSheet
            setup(presented)
        },
            completion: completion
        )
    }

    func presentNavigableSheet<Input>(
        _ route: KeyPath<Self, RoutePath<Self, Input>>,
        _ input: Input = (),
        animated: Bool = true,
        setup: PresentSetup = {_ in},
        completion: PresentCompletion? = nil
    ) {
        let viewController = makeViewController(for: route, input)
        presentNavigation(
            viewController,
            animated: animated,
            setup: { presented in
            presented.modalPresentationStyle = .pageSheet
            setup(presented)
        },
            completion: completion
        )
    }
}

// MARK: - Present Cover
public extension UIRouter {
    func presentCover<Input>(
        _ route: KeyPath<Self, RoutePath<Self, Input>>,
        _ input: Input = (),
        animated: Bool = true,
        setup: PresentSetup = {_ in},
        completion: PresentCompletion? = nil
    ) {
        let viewController = makeViewController(for: route, input)
        present(
            viewController: viewController,
            animated: animated,
            setup: { presented in
            presented.modalPresentationStyle = .overFullScreen
            setup(presented)
        },
            completion: completion
        )
    }

    func presentNavigableCover<Input>(
        _ route: KeyPath<Self, RoutePath<Self, Input>>,
        _ input: Input = (),
        animated: Bool = true,
        setup: PresentSetup = {_ in},
        completion: PresentCompletion? = nil
    ) {
        let viewController = makeViewController(for: route, input)
        presentNavigation(
            viewController,
            animated: animated,
            setup: { presented in
            presented.modalPresentationStyle = .overFullScreen
            setup(presented)
        },
            completion: completion
        )
    }
}
