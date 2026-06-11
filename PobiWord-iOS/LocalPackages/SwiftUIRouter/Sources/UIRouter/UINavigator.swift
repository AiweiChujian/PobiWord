//
//  File.swift
//  SwiftUIRouter
//
//  Created by Avery on 2026/4/3.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
public struct UINavigator {
    public let appWindow: UIWindow

    public init(_ appWindow: UIWindow) {
        self.appWindow = appWindow
    }
}

// MARK: - Top ViewController
public extension UINavigator {
    /// 最上层的 ViewController
    var topViewController: UIViewController {
        guard let root = appWindow.rootViewController else {
            assertionFailure("rootViewController is nil.")
            return .init()
        }
        return root.topMost()
    }

    /// 最上层的 NavigationController
    var topNavigationController: UINavigationController? {
        topViewController.navigationController
    }
}

// MARK: - Type Aliases
public extension UINavigator {
    typealias PresentSetup = (_ presented: UIViewController) -> Void
    typealias PresentCompletion = () -> Void
}

// MARK: - SwiftUIViewController 工厂
public extension UINavigator {
    /// 根据 AnyView 创建 SwiftUIViewController
    static func makeViewController(
        anyView: AnyView,
        routeId: AnyHashable,
        routeTitle: String,
        enablePopGesture: Bool = true,
        drawerPresentation: DrawerModalPresentation? = nil
    ) -> SwiftUIViewController {
        let viewController = SwiftUIViewController(
            rootView: anyView,
            routeId: routeId,
            routeTitle: routeTitle,
            enablePopGesture: enablePopGesture,
            drawerPresentation: drawerPresentation
        )
        viewController.title = routeTitle
        return viewController
    }
    
    func viewController(
        for anyView: AnyView,
        routeId: AnyHashable,
        routeTitle: String,
        enablePopGesture: Bool = true
    ) -> SwiftUIViewController {
        Self.makeViewController(anyView: anyView, routeId: routeId, routeTitle: routeTitle, enablePopGesture: enablePopGesture)
    }
}

// MARK: - Push
public extension UINavigator {
    /// 通用 push 方法
    func push(
        _ viewController: UIViewController,
        animated: Bool = true,
        zoomSourceView: UIView? = nil,
        isExclusive: Bool = false,
        exclusiveFilter: @escaping (UIViewController) -> Bool = { _ in false },
        completion: (() -> Void)? = nil
    ) {
        guard let navigationController = topNavigationController else {
            return
        }
        if #available(iOS 18.0, *), let zoomSourceView {
            viewController.preferredTransition = .zoom { context in
                zoomSourceView
            }
        }
        navigationController.performNavigation(animated: animated, completion: {
            defer { completion?() }
            if isExclusive, !navigationController.viewControllers.isEmpty {
                var children = navigationController.viewControllers
                let last = children.removeLast()
                children = children.filter {
                    !exclusiveFilter($0)
                }
                children.append(last)
                navigationController.setViewControllers(children, animated: false)
            }
        }) {
            navigationController.pushViewController(viewController, animated: animated)
        }
    }

    /// push 一组视图控制器
    func push(viewControllers: [UIViewController], animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let navigationController = topNavigationController else { return }
        var children = navigationController.viewControllers
        children.append(contentsOf: viewControllers)
        navigationController.performNavigation(animated: animated, completion: completion) {
            navigationController.setViewControllers(children, animated: animated)
        }
    }
}

// MARK: - Pop
public extension UINavigator {
    /// pop 视图控制器
    func pop(_ count: Int = 1, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let navigationController = topNavigationController,
              count > 0, !navigationController.viewControllers.isEmpty
        else { return }
        let count = min(count, navigationController.viewControllers.count - 1)
        navigationController.performNavigation(animated: animated, completion: completion) {
            if count == 1 {
                navigationController.popViewController(animated: animated)
            } else if let target = navigationController.viewControllers.dropLast(count).last {
                navigationController.popToViewController(target, animated: animated)
            }
        }
    }

    /// pop 到根视图控制器
    func popToRoot(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let navigationController = topNavigationController else { return }
        navigationController.performNavigation(animated: animated, completion: completion) {
            navigationController.popToRootViewController(animated: animated)
        }
    }

    /// pop 到最近一个指定类型的 ViewController
    func popToLast<T: UIViewController>(_ targetType: T.Type, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let navigationController = topNavigationController,
              let target = navigationController.viewControllers.last(where: { type(of: $0) == targetType })
        else { return }
        navigationController.performNavigation(animated: animated, completion: completion) {
            navigationController.popToViewController(target, animated: animated)
        }
    }
}

// MARK: - Present
public extension UINavigator {
    /// 通用的 present 方法
    func present(
        viewController: UIViewController,
        animated: Bool = true,
        transitioningDelegate: UIViewControllerTransitioningDelegate? = nil,
        setup: PresentSetup = { _ in },
        completion: PresentCompletion? = nil
    ) {
        if let delegate = transitioningDelegate {
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = delegate
        }
        setup(viewController)
        let topViewController = topViewController
        topViewController.present(viewController, animated: animated, completion: completion)
    }

    func presentNavigation<T: UINavigationController>(
        _ rootViewController: UIViewController,
        navigationControllerType: T.Type = UINavigationController.self,
        animated: Bool = true,
        transitioningDelegate: UIViewControllerTransitioningDelegate? = nil,
        setup: PresentSetup = { _ in },
        completion: PresentCompletion? = nil
    ) {
        guard topNavigationController != nil else { return }
        let viewController = navigationControllerType.init(rootViewController: rootViewController)
        present(
            viewController: viewController,
            animated: animated,
            transitioningDelegate: transitioningDelegate,
            setup: setup,
            completion: completion
        )
    }
}

// MARK: - Dismiss
public extension UINavigator {
    func dismiss(animated: Bool = true, completion: PresentCompletion? = nil) {
        let viewController = topViewController
        let presentingViewController = viewController.presentingViewController ?? viewController.navigationController?.presentingViewController
        presentingViewController?.dismiss(animated: animated, completion: completion)
    }
}
