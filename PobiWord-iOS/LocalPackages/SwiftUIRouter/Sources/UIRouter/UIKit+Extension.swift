//
//  File.swift
//  MVVMRedux
//
//  Created by Avery on 2025/6/30.
//

import Foundation
import UIKit

extension UIWindow {
    static var firstWindow: UIWindow {
        if let window = UIApplication.shared.delegate?.window, let window = window {
            return window
        }
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene}).first?.windows.first else {
            assertionFailure("Not set first window")
            return .init()
        }
        return window
    }
}

public extension UIViewController {
    static func topMost(of viewController: UIViewController) -> UIViewController {
      // PresentedViewController
        if let presentedViewController = viewController.presentedViewController, !presentedViewController.isBeingDismissed {
        return self.topMost(of: presentedViewController)
      }
      // UITabBarController
      if let tabBarController = viewController as? UITabBarController,
        let selectedViewController = tabBarController.selectedViewController {
        return self.topMost(of: selectedViewController)
      }
      // UINavigationController
      if let navigationController = viewController as? UINavigationController,
         let topViewController = navigationController.topViewController {
        return self.topMost(of: topViewController)
      }
      return viewController
    }
    
    func topMost() -> UIViewController {
        Self.topMost(of: self)
    }
}

extension UINavigationController {
    /// 执行导航操作，并在转场动画完成后调用 completion
    func performNavigation(animated: Bool = true, completion: (() -> Void)?, action: () -> Void) {
        action()
        guard animated, let coordinator = transitionCoordinator else {
            completion?()
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in
            completion?()
        }
    }
}
