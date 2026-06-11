//
//  File 2.swift
//  SwiftUIRouter
//
//  Created by Avery on 2026/4/3.
//

import Foundation
import UIKit
import SwiftUI
import UIRouter

public struct ExportedRoute {
    public var router: any ExportableRouter
    public var path: ExportableRoutePath

    public init(router: any ExportableRouter, path: ExportableRoutePath) {
        self.router = router
        self.path = path
    }
}

@MainActor
public protocol GlobalRouter: AnyObject {
    associatedtype RouteKey: Hashable
    associatedtype RootParams
    
    var appWindow: UIWindow { get }
    
    init(appWindow: UIWindow)
    
    var registeredRoutes: [RouteKey: ExportedRoute] { get set }
    
    typealias Root = RootPathWrapper
    
    var rootView: RootPath<Self, RootParams> { get }
}

public extension GlobalRouter {
    init<W: UIWindow>(_ scene: UIWindowScene, windowType: W.Type = UIWindow.self) {
        let window = windowType.init(windowScene: scene)
        self.init(appWindow: window)
    }

    /// UINavigator 实例，封装基于 UIWindow 的导航能力
    var navigator: UINavigator { UINavigator(appWindow) }

    /// 最上层的 NavigationController
    var topNavigationController: UINavigationController? { navigator.topNavigationController }

    func makeRootViewController<N: UINavigationController>(
        _ params: RootParams,
        drawerPresentation: DrawerModalPresentation? = nil,
        rootTitle: String = "Root",
        navigationControllerType: N.Type = UINavigationController.self
    ) -> N {
        let rootPath = self[keyPath: \.rootView]
        let rootView = rootPath.using(router: self, input: params)

        let viewController = UINavigator.makeViewController(
            anyView: rootView,
            routeId: ObjectIdentifier(self),
            routeTitle: rootTitle,
            enablePopGesture: false,
            drawerPresentation: drawerPresentation
        )
        viewController.title = rootTitle
        return navigationControllerType.init(rootViewController: viewController)
    }

    func makeRootAndVisible<N: UINavigationController>(
        _ params: RootParams,
        drawerPresentation: DrawerModalPresentation? = nil,
        rootTitle: String = "Root",
        navigationControllerType: N.Type = UINavigationController.self
    ) {
        let rootViewController = makeRootViewController(
            params,
            drawerPresentation: drawerPresentation,
            rootTitle: rootTitle,
            navigationControllerType: navigationControllerType
        )
        appWindow.rootViewController = rootViewController
        appWindow.makeKeyAndVisible()
    }
}

public extension GlobalRouter where RootParams == Void {
    func makeRootAndVisible<N: UINavigationController>(
        drawerPresentation: DrawerModalPresentation? = nil,
        rootTitle: String = "Root",
        navigationControllerType: N.Type = UINavigationController.self
    ) {
        makeRootAndVisible((), drawerPresentation: drawerPresentation, rootTitle: rootTitle, navigationControllerType: navigationControllerType)
    }

    func makeRootViewController<N: UINavigationController>(
        drawerPresentation: DrawerModalPresentation? = nil,
        rootTitle: String = "Root",
        navigationControllerType: N.Type = UINavigationController.self
    ) -> N {
        makeRootViewController((), drawerPresentation: drawerPresentation, rootTitle: rootTitle, navigationControllerType: navigationControllerType)
    }
}

public extension GlobalRouter {
    func register<R: ExportableRouter>(_ router: R) where R.RouteKey == Self.RouteKey {
        registeredRoutes = router.exportedPaths.reduce(into: registeredRoutes) { partialResult, part in
            partialResult[part.key] = .init(router: router, path: part.value)
        }
    }

    func routeViewForKey<Input>(_ key: RouteKey, input: Input = ()) -> AnyView? {
        guard let route = registeredRoutes[key] else {
            assertionFailure("routeKey(\(key)) not registered.")
            return nil
        }
        let anyView = route.path.buildView(with: route.router, input: input)
        assert(anyView != nil, "Router or Input type mismatch for routeKey: \(key)")
        return anyView
    }

    func viewControllerForKey<Input>(
        _ key: RouteKey,
        input: Input = (),
        title: String? = nil,
        enablePopGesture: Bool = true,
        drawerPresentation: DrawerModalPresentation? = nil
    ) -> SwiftUIViewController? {
        let anyView = routeViewForKey(key, input: input)
        guard let anyView else { return nil }
        return UINavigator.makeViewController(
            anyView: anyView,
            routeId: key,
            routeTitle: title ?? "\(key)",
            enablePopGesture: enablePopGesture,
            drawerPresentation: drawerPresentation
        )
    }
}

// MARK: - Push
public extension GlobalRouter {
    func push<Input>(
        _ routeKey: RouteKey,
        _ input: Input = (),
        animated: Bool = true,
        zoomSourceView: UIView? = nil,
        enablePopGesture: Bool = true,
        isExclusive: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        let viewController = viewControllerForKey(routeKey, input: input, enablePopGesture: enablePopGesture)
        guard let viewController = viewController else { return }
        navigator.push(viewController, animated: animated, zoomSourceView: zoomSourceView, isExclusive: isExclusive, completion: completion)
    }
}

// MARK: - Pop
public extension GlobalRouter {
    /// pop 视图控制器
    func pop(_ count: Int = 1, animated: Bool = true, completion: (() -> Void)? = nil) {
        navigator.pop(count, animated: animated, completion: completion)
    }

    /// pop 到根视图控制器
    func popToRoot(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigator.popToRoot(animated: animated, completion: completion)
    }
}
