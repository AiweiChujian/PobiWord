//
//  UIKitViewController.swift
//  MVVMRedux
//
//  Created by Avery on 2025/7/25.
//

import Foundation
import UIKit

open class UIKitViewController<Router: UIRouter>: UIViewController, UIGestureRecognizerDelegate {
    public internal(set) weak var router: Router?

    open var shouldHideNavigationBar: Bool {
        true
    }

    open var enablePopGesture: Bool {
        true
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 更新 StatusBarStyle
        setNeedsStatusBarAppearanceUpdate()
        navigationController?
            .setNavigationBarHidden(shouldHideNavigationBar, animated: animated)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self) {
            // RootViewController 如果允许边缘手势, 将引起导航 BUG
            guard let count = navigationController?.viewControllers.count,
                  count > 1 else {
                return false
            }
            return enablePopGesture
        }
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // EdgePan 在其它手势失败后再被识别
        gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self)
    }
}
