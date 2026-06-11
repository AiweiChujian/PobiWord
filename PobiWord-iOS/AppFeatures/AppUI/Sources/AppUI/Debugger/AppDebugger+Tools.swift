//
//  File.swift
//  AppUI
//
//  Created by Avery on 2025/4/27.
//

import Foundation
import UIKit
import SwiftUI

extension AppDebugger {
    enum Tools: CaseIterable {
    }
}

extension AppDebugger.Tools {
    @MainActor
    private func debuggerWindow() -> UIWindow? {
        let windows = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
        return windows.sorted { $0.windowLevel > $1.windowLevel }.first
    }
    
    @MainActor
    private var rootNavigationController: UINavigationController? {
        guard let window = debuggerWindow(),
              let nav = window.rootViewController as? UINavigationController else {
            assertionFailure("获取 Debugger RootNavigationController 失败")
            return nil
        }
        return nav
    }
    
    @MainActor
    private func push<ToolView: View>(to toolView: ToolView, title: String) {
        guard let rootNav = rootNavigationController else {
            return
        }
        let hostingController = UIHostingController(rootView: toolView)
        hostingController.title = title
        rootNav.pushViewController(hostingController, animated: true)
    }
    
    @MainActor
    private func toastAlert(_ message: String, title: String? = nil) {
        guard let rootNav = rootNavigationController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "确定", style: .cancel))
        rootNav.present(alert, animated: true)
    }
}

extension AppDebugger.Tools {
    var title: String {
        "自定义工具标题"
    }
    
    func entryPoint() {
        Task{@MainActor in
            
        }
    }
}
