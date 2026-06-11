//
//  GlobalRouter+Present.swift
//  SwiftUIRouter
//
//  Created by Avery on 2026/4/3.
//

import Foundation
import UIKit
import SwiftUI
import UIRouter

// MARK: - Type Aliases
public extension GlobalRouter {
    typealias PresentSetup = UINavigator.PresentSetup
    typealias PresentCompletion = UINavigator.PresentCompletion
}

// MARK: - Dismiss
public extension GlobalRouter {
    /// dismiss 当前 presented 的视图控制器
    func dismiss(animated: Bool = true, completion: PresentCompletion? = nil) {
        navigator.dismiss(animated: animated, completion: completion)
    }
}

// MARK: - Present
public extension GlobalRouter {
    /// present 指定 routeKey 对应的视图
    func present<Input>(
        _ routeKey: RouteKey,
        _ input: Input = (),
        animated: Bool = true,
        drawerPresentation: DrawerModalPresentation? = nil,
        transitioningDelegate: UIViewControllerTransitioningDelegate? = nil,
        setup: PresentSetup = { _ in },
        completion: PresentCompletion? = nil
    ) {
        let viewController = viewControllerForKey(routeKey, input: input, drawerPresentation: drawerPresentation)
        guard let viewController = viewController else { return }
        navigator.present(
            viewController: viewController,
            animated: animated,
            transitioningDelegate: transitioningDelegate,
            setup: setup,
            completion: completion
        )
    }

    /// present 指定 routeKey 对应的视图，包裹在 NavigationController 中
    func presentNavigation<Input, N: UINavigationController>(
        _ routeKey: RouteKey,
        _ input: Input = (),
        animated: Bool = true,
        enablePopGesture: Bool = true,
        navigationControllerType: N.Type = UINavigationController.self,
        transitioningDelegate: UIViewControllerTransitioningDelegate? = nil,
        setup: PresentSetup = { _ in },
        completion: PresentCompletion? = nil
    ) {
        let viewController = viewControllerForKey(routeKey, input: input, enablePopGesture: enablePopGesture)
        guard let viewController = viewController else { return }
        navigator.presentNavigation(
            viewController,
            navigationControllerType: navigationControllerType,
            animated: animated,
            transitioningDelegate: transitioningDelegate,
            setup: setup,
            completion: completion
        )
    }
}

// MARK: - Present Sheet
public extension GlobalRouter {
    /// 以 pageSheet 样式 present 指定 routeKey 对应的视图
    func presentSheet<Input>(
        _ routeKey: RouteKey,
        _ input: Input = (),
        animated: Bool = true,
        setup: PresentSetup = { _ in },
        completion: PresentCompletion? = nil
    ) {
        let viewController = viewControllerForKey(routeKey, input: input)
        guard let viewController = viewController else { return }
        navigator.present(
            viewController: viewController,
            animated: animated,
            setup: { presented in
                presented.modalPresentationStyle = .pageSheet
                setup(presented)
            },
            completion: completion
        )
    }

    /// 以 pageSheet 样式 present 指定 routeKey 对应的视图，包裹在 NavigationController 中
    func presentNavigableSheet<Input, N: UINavigationController>(
        _ routeKey: RouteKey,
        _ input: Input = (),
        animated: Bool = true,
        enablePopGesture: Bool = true,
        navigationControllerType: N.Type = UINavigationController.self,
        setup: PresentSetup = { _ in },
        completion: PresentCompletion? = nil
    ) {
        let viewController = viewControllerForKey(routeKey, input: input, enablePopGesture: enablePopGesture)
        guard let viewController = viewController else { return }
        navigator.presentNavigation(
            viewController,
            navigationControllerType: navigationControllerType,
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
public extension GlobalRouter {
    /// 以 overFullScreen 样式 present 指定 routeKey 对应的视图
    func presentCover<Input>(
        _ routeKey: RouteKey,
        _ input: Input = (),
        animated: Bool = true,
        setup: PresentSetup = { _ in },
        completion: PresentCompletion? = nil
    ) {
        let viewController = viewControllerForKey(routeKey, input: input)
        guard let viewController = viewController else { return }
        navigator.present(
            viewController: viewController,
            animated: animated,
            setup: { presented in
                presented.modalPresentationStyle = .overFullScreen
                setup(presented)
            },
            completion: completion
        )
    }

    /// 以 overFullScreen 样式 present 指定 routeKey 对应的视图，包裹在 NavigationController 中
    func presentNavigableCover<Input, N: UINavigationController>(
        _ routeKey: RouteKey,
        _ input: Input = (),
        animated: Bool = true,
        enablePopGesture: Bool = true,
        navigationControllerType: N.Type = UINavigationController.self,
        setup: PresentSetup = { _ in },
        completion: PresentCompletion? = nil
    ) {
        let viewController = viewControllerForKey(routeKey, input: input, enablePopGesture: enablePopGesture)
        guard let viewController = viewController else { return }
        navigator.presentNavigation(
            viewController,
            navigationControllerType: navigationControllerType,
            animated: animated,
            setup: { presented in
                presented.modalPresentationStyle = .overFullScreen
                setup(presented)
            },
            completion: completion
        )
    }
}
