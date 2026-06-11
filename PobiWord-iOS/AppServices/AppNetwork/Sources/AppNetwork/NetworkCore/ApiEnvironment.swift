//
//  ApiEnvironment.swift
//  STNetwork
//
//  Created by Avery on 2025/4/27.
//

import Foundation

/// API环境枚举
public enum ApiEnvironment {
    /// 开发环境
    case development
    /// 生产环境
    case production
    
    /// 检查是否为沙盒环境
    private static var isSandbox: Bool {
        guard let path = Bundle.main.appStoreReceiptURL?.path() else {
            return false
        }
        return path.contains("sandboxReceipt")
    }
    
    private static var buildVersion: Int {
        // Bundle.main 代表当前应用的 Bund
        guard let value = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
            return 0
        }
        return Int(value) ?? 0
    }
}

// MARK: - 环境判断
public extension ApiEnvironment {
    /// 获取当前环境
    static let current: Self = {
#if !DEBUG && !targetEnvironment(simulator)
        guard isSandbox() else { return .production } // 兜底配置, Release
#endif
        return (buildVersion % 2 == 0) ? .production : .development
    }()
    
    /// 判断是否链接的测试环境
    static var isDevelopment: Bool {
        current == .development
    }
}

// MARK: - BaseURL
public extension ApiEnvironment {
    /// 获取当前环境的基础URL
    var baseURL: URL {
        assertionFailure("设置 base URL")
        switch self {
        case .development:
            return URL(string: "https://style.wisebox.ai/api")!
        case .production:
            return URL(string: "https://vibepic.ai/api")!
        }
    }
    
    /// 静态访问当前环境的基础URL
    static var baseURL: URL {
        current.baseURL
    }
}

// MARK: - 环境切换
public extension ApiEnvironment {
    /// 这里确定 DEBUG 版应用（开发、调试）链接的服务器环境
    private static var debugEnvironment: Self {
         .development
    }
    
    /// 这里确定 RELEASE 版应用（TestFlight 和 AppStore） 链接的服务器环境
    private static var releaseEnvironment: Self {
         .production
    }
}
