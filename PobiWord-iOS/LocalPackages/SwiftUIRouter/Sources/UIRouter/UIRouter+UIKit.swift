//
//  UIRouter+UIKit.swift
//  MVVMRedux
//
//  Created by Avery on 2025/7/25.
//

import Foundation
import UIKit

public extension UIRouter {
    typealias PresentSetup = UINavigator.PresentSetup
    typealias PresentCompletion = UINavigator.PresentCompletion
}

// MARK: - Push
public extension UIRouter {
    /// push 一个视图控制器
    func push(
        _ viewController: UIViewController,
        animated: Bool = true,
        zoomSourceView: UIView? = nil,
        isExclusive: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        if let viewController = viewController as? UIKitViewController<Self> {
            viewController.router = self
        }
        let targetType = type(of: viewController)
        navigator.push(
            viewController,
            animated: animated,
            zoomSourceView: zoomSourceView,
            isExclusive: isExclusive,
            exclusiveFilter: { type(of: $0) == targetType },
            completion: completion
        )
    }

    /// push 一组视图控制器
    func push(viewControllers: [UIViewController], animated: Bool = true, completion: (() -> Void)? = nil) {
        navigator.push(viewControllers: viewControllers, animated: animated, completion: completion)
    }

    /// pop 视图控制器
    func pop(_ count: Int = 1, animated: Bool = true, completion: (() -> Void)? = nil) {
        navigator.pop(count, animated: animated, completion: completion)
    }

    /// pop 到根视图控制器
    func popToRoot(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigator.popToRoot(animated: animated, completion: completion)
    }

    /// pop 到最近一个指定类型的 ViewController
    func popToLast<T: UIViewController>(_ targetType: T.Type, animated: Bool = true, completion: (() -> Void)? = nil) {
        navigator.popToLast(targetType, animated: animated, completion: completion)
    }
}

// MARK: - Present
public extension UIRouter {
    /// 通用的 present 方法
    func present(
        viewController: UIViewController,
        animated: Bool = true,
        transitioningDelegate: UIViewControllerTransitioningDelegate? = nil,
        setup: PresentSetup = { _ in },
        completion: PresentCompletion? = nil
    ) {
        if let viewController = viewController as? UIKitViewController<Self> {
            viewController.router = self
        }
        navigator.present(
            viewController: viewController,
            animated: animated,
            transitioningDelegate: transitioningDelegate,
            setup: setup,
            completion: completion
        )
    }

    func presentNavigation<T: UINavigationController>(
        _ rootViewController: UIViewController,
        navigationControllerType: T.Type = UINavigationController.self,
        animated: Bool = true,
        transitioningDelegate: UIViewControllerTransitioningDelegate? = nil,
        setup: PresentSetup = { _ in },
        completion: PresentCompletion? = nil
    ) {
        if let rootViewController = rootViewController as? UIKitViewController<Self> {
            rootViewController.router = self
        }
        navigator.presentNavigation(
            rootViewController,
            navigationControllerType: navigationControllerType,
            animated: animated,
            transitioningDelegate: transitioningDelegate,
            setup: setup,
            completion: completion
        )
    }
}
