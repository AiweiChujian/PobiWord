//
//  UIRouter.swift
//
//  Created by Avery on 2025/4/26.
//

import Foundation
@_exported import UIKit
@_exported import Router

public protocol UIRouter: Routable {
    var appWindow: UIWindow { get }

    init(appWindow: UIWindow)
}

public extension UIRouter {
    static func makeRoot<Input, W: UIWindow, N: UINavigationController>(
        _ scene: UIWindowScene,
        route: KeyPath<Self, RoutePath<Self, Input>>,
        _ input: Input = (),
        drawerPresentation: DrawerModalPresentation? = nil,
        windowType: W.Type = UIWindow.self,
        navigationControllerType: N.Type = UINavigationController.self
    ) -> Self {
        let window = windowType.init(windowScene: scene)
        let router = Self(appWindow: window)
        let result = router.parse(route: route)
        let view = result.routePath.using(router: router, input: input)

        let viewController = UINavigator.makeViewController(
            anyView: view,
            routeId: ObjectIdentifier(route),
            routeTitle: result.title,
            enablePopGesture: false,
            drawerPresentation: drawerPresentation
        )

        router.appWindow.rootViewController = navigationControllerType.init(rootViewController: viewController)
        router.appWindow.makeKeyAndVisible()
        return router
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// UINavigator 实例，封装基于 UIWindow 的导航能力
    var navigator: UINavigator { UINavigator(appWindow) }

    /// 最上层的 NavigationController
    var topNavigationController: UINavigationController? { navigator.topNavigationController }
}

public extension UIRouter {
    /// 根据 RoutePath 创建 viewController （含参）
    func makeViewController<Input>(for route: KeyPath<Self, RoutePath<Self, Input>>, _ input: Input = (), enablePopGesture: Bool = true) -> SwiftUIViewController {
        let result = parse(route: route)
        let view = result.routePath.using(router: self, input: input)
        return navigator.viewController(
            for: view,
            routeId: ObjectIdentifier(route),
            routeTitle: result.title,
            enablePopGesture: enablePopGesture
        )
    }

    /// NavigationController 中所有 指定 RoutePath 对应的 ViewController
    func viewControllersIn<Input>(navigationController: UINavigationController?, for route: KeyPath<Self, RoutePath<Self, Input>>) -> [SwiftUIViewController]? {
        guard let navigationController = navigationController else {
            return nil
        }
        let routeId: AnyHashable = ObjectIdentifier(route)
        return navigationController.viewControllers.compactMap {
            guard let viewController = $0 as? SwiftUIViewController,
                  viewController.routeId == routeId
            else { return nil}
            return viewController
        }
    }

    /// 最近一个 RoutePath 对应的视图控制器
    func lastViewControllerInTop<Input>(for route: KeyPath<Self, RoutePath<Self, Input>>) -> SwiftUIViewController? {
        viewControllersIn(navigationController: topNavigationController, for: route)?.last
    }
}

// MARK: - Routable Conformance
public extension UIRouter {
    func push<Input>(_ route: KeyPath<Self, RoutePath<Self, Input>>, _ input: Input = ()) {
        push(route, input, animated: true)
    }

    func pop(_ count: Int) {
        pop(count, animated: true)
    }

    func popToRoot() {
        popToRoot(animated: true)
    }
}

// MARK: - push
public extension UIRouter {
    /// push 指定的 route path （含参）
    func push<Input>(
        _ route: KeyPath<Self, RoutePath<Self, Input>>,
        _ input: Input = (),
        animated: Bool = true,
        zoomSourceView: UIView? = nil,
        enablePopGesture: Bool = true,
        isExclusive: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        let result = parse(route: route)
        let routeId: AnyHashable = route
        let view = result.routePath.using(router: self, input: input)
        let viewController = navigator.viewController(for: view, routeId: routeId, routeTitle: result.title, enablePopGesture: enablePopGesture)
        navigator.push(
            viewController,
            animated: animated,
            zoomSourceView: zoomSourceView,
            isExclusive: isExclusive,
            exclusiveFilter: {
                guard let vc = $0 as? SwiftUIViewController else {
                    return false
                }
                return vc.routeId == routeId
            },
            completion: completion
        )
    }
}

// MARK: - pop
public extension UIRouter {
    /// pop 到最近一个 RoutePath
    func popToLast<Input>(_ route: KeyPath<Self, RoutePath<Self, Input>>, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let navigationController = topNavigationController,
              let target = lastViewControllerInTop(for: route)
        else { return }
        navigationController.performNavigation(animated: animated, completion: completion) {
            navigationController.popToViewController(target, animated: animated)
        }
    }
}
