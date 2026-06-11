//
//  File.swift
//  AppFoundation
//
//  Created by Avery on 2026/4/9.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum AppContext {}

public extension AppContext {
    static let version: String = {
        guard let infoDictionary = Bundle.main.infoDictionary else { return "1.0.0" }
        let majorVersion = infoDictionary["CFBundleShortVersionString"] as? String
        return majorVersion ?? "1.0.0"
    }()
    
    static let buildVersion: Int = {
        // Bundle.main 代表当前应用的 Bund
        guard let value = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
            return 0
        }
        return Int(value) ?? 0
    }()
    
    static let appName: String = {
        assertionFailure("设置 App Name")
        return "AppDemo"
    }()
    
    
    static var isSandbox: Bool {
        guard let path = Bundle.main.appStoreReceiptURL?.path() else {
            return false
        }
        return path.contains("sandboxReceipt")
    }

    static var systemName: String {
        #if canImport(UIKit) && !os(macOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "iOS"
        case .pad:
            return "iPadOS"
        case .mac:
            return "MacOS"
        default:
            return "Other"
        }
        #else
        #if os(macOS)
        return "macOS"
        #else
        return "Unknown"
        #endif
        #endif
    }

    static var systemVersion: String {
        #if canImport(UIKit) && !os(macOS)
        return UIDevice.current.systemVersion
        #else
        #if os(macOS)
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        return "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        #else
        return "Unknown"
        #endif
        #endif
    }

    static var versionInfo: String {
        "\(systemName)(\(systemVersion))/v\(version)(\(buildVersion))"
    }
}
