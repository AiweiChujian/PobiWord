//
//  File.swift
//  MVVMRedux
//
//  Created by Avery on 2025/6/30.
//

import Foundation
import SwiftUI
import UIKit

public final class SwiftUIViewController: UIHostingController<AnyView> {
    let routeId: AnyHashable

    let routeTitle: String

    let enablePopGesture: Bool

    let drawerPresentation: DrawerModalPresentation?

    public init(
        rootView: AnyView,
        routeId: AnyHashable,
        routeTitle: String,
        enablePopGesture: Bool,
        drawerPresentation: DrawerModalPresentation? = nil
    ) {
        self.routeId = routeId
        self.routeTitle = routeTitle
        self.enablePopGesture = enablePopGesture
        self.drawerPresentation = drawerPresentation
        super.init(rootView: rootView)
        hidesBottomBarWhenPushed = true
        if let gesture = drawerPresentation?.presentGesture {
            gesture.delegate = self
            view.addGestureRecognizer(gesture)
        }
        
        debugPrint("🆕 已创建: \(routeTitle)")
    }
    
    deinit {
        debugPrint("🚮 已释放: \(routeTitle)")
    }
    
    @MainActor @preconcurrency
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            .setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
}

extension SwiftUIViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let drawerPresentation = drawerPresentation,
           gestureRecognizer === drawerPresentation.presentGesture {
            let locationX = gestureRecognizer.location(in: view).x
            let width = view.bounds.width * drawerPresentation.presentGesturePercent
            return locationX <= width
        }
        
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
        false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // EdgePan 在其它手势失败后再被识别
        gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self)
    }
}
