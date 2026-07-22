//
//  ServerEnvironment.swift
//  STNetwork
//
//  Created by Avery on 2025/4/27.
//

import Foundation

/// API环境枚举
nonisolated public enum ServerEnvironment: Sendable {
    /// 开发环境
    case development
    /// 生产环境
    case production
}

// MARK: - 环境判断
public extension ServerEnvironment {
    /// 获取当前环境
    nonisolated static let current: Self = {
#if !DEBUG && !targetEnvironment(simulator)
        guard AppContext.isSandbox else { return .production } // 兜底配置, Release
#endif
        return (AppContext.buildVersion % 2 == 0) ? .production : .development
    }()
    
    /// 判断是否链接的测试环境
    nonisolated static var isDevelopment: Bool {
        current == .development
    }
}

nonisolated public enum ServerHost {
    /// 静态访问当前环境的基础URL
    nonisolated static var baseURL: URL {
        assertionFailure("设置 base URL")
        switch ServerEnvironment.current {
        case .development:
            return URL(string: "https://style.wisebox.ai/api")!
        case .production:
            return URL(string: "https://vibepic.ai/api")!
        }
    }
}
