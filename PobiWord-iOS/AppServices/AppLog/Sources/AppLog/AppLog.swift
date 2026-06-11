//
//  Logger.swift
//  Sider
//
//  Created by Avery on 2024/10/18.
//

import Foundation
import SwiftyBeaver
import OSLog
import os.signpost
import Combine
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public let log = AppLogger.self

extension String {
    func appendingPathComponent(_ pathComponent: String) -> String {
        let path: String
        if self.hasSuffix("/") {
            if pathComponent.hasPrefix("/") {
                path = self + pathComponent.dropFirst()
            } else {
                path = self + pathComponent
            }
        } else {
            if pathComponent.hasPrefix("/") {
                path = self + pathComponent
            } else {
                path = self + "/" + pathComponent
            }
        }

        if path.count > 1 && path.hasSuffix("/") {
            return String(path.dropLast())
        } else {
            return path
        }
    }
}

public enum AppLogger {
    fileprivate static var isDevelopment = true
    
    private static func logDirectory(with path: String) -> String {
        let document = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
        return document.path().appendingPathComponent(path)
    }
    
    public static let errorLogSubject = PassthroughSubject<String, Never>()
    
    @MainActor
    public static func setup(isDevelopment: Bool, savePath: String? = nil)  {
        AppLogger.isDevelopment = isDevelopment
        guard let path = savePath else { return }
        let logDirectory = logDirectory(with: path)
        cleanExpiredLogs(from: logDirectory)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = dateFormatter.string(from: .now)
        let filePath = logDirectory.appendingPathComponent(timestamp) as NSString
        let fullPath = filePath.appendingPathExtension("log") ?? "\(filePath).log"
        
        let file = FileDestination()
        file.format = "\(versionInfo) $Dyyyy-MM-dd HH:mm:ss.SSS$d $L [$N.$F:$l] $M"
        if isDevelopment {
            file.minLevel = .debug
        } else {
            file.minLevel = .warning
        }
        file.logFileURL = URL(fileURLWithPath: fullPath)
        SwiftyBeaver.addDestination(file)
    }
    /// 清理过期日志
    private static func cleanExpiredLogs(from directory: String, completion: ((_ succeed: Bool) -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileManager = FileManager.default
                let fileURLs = try fileManager.contentsOfDirectory(
                    at: URL(fileURLWithPath: directory),
                    includingPropertiesForKeys: [.creationDateKey],
                    options: .skipsHiddenFiles
                )
                let expirationTime: TimeInterval = 14 * 24 * 60 * 60  // 14 天
                let now = Date().timeIntervalSince1970  // 当前时间的时间戳
                for fileURL in fileURLs {
                    // 获取文件的创建日期时间戳
                    let resourceValues = try fileURL.resourceValues(forKeys: [.creationDateKey])
                    if let creationDate = resourceValues.creationDate {
                        let creationTimestamp = creationDate.timeIntervalSince1970
                        // 判断文件是否超过 14 天
                        if now - creationTimestamp >= expirationTime {
                            try fileManager.removeItem(at: fileURL)
                        }
                    }
                }
                completion?(true)
            } catch {
                completion?(false)
            }
        }
    }
}

public extension AppLogger {
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
    
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    static var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
    
    static var versionInfo: String {
        "\(systemName)(\(systemVersion))/v\(appVersion)(\(appBuild))"
    }
}

// MARK: - OSLogDestination
struct OSLogger {
    var subsystem: String
    var category: String
    
    init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
    }
    
    struct LevelPrefix {
        var verbose = "✅VERBOSE"
        var debug = "💡DEBUG"
        var info = "❗️INFO"
        var warning = "⚠️WARNING"
        var error = "❌ERROR"
        var critical = "CRITICAL"
        var fault = "FAULT"
    }
    
    var levelPrefix = LevelPrefix()
    
    var dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    
    var isDevelopment: Bool {
        AppLogger.isDevelopment
    }
    
    private func formattedString(_ level: SwiftyBeaver.Level, msg: String, file: String, function: String, line: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let timestamp = dateFormatter.string(from: .now)
        let prefix: String
        switch level {
        case .verbose:
            prefix = levelPrefix.verbose
        case .debug:
            prefix = levelPrefix.debug
        case .info:
            prefix = levelPrefix.info
        case .warning:
            prefix = levelPrefix.warning
        case .error:
            prefix = levelPrefix.error
        case .critical:
            prefix = levelPrefix.critical
        case .fault:
            prefix = levelPrefix.fault
        }
        return "\(timestamp) [\(function):\(line)] \(prefix): \(msg)"
    }
    
    func send(_ level: SwiftyBeaver.Level, msg: String, file: String, function: String, line: Int, context: Any? = nil) {
        let message = formattedString(level, msg: msg, file: file, function: function, line: line)
        let logger = Logger(subsystem: subsystem, category: category)
        switch level {
        case .verbose:
            logger.trace("\(message)")
        case .debug:
            if isDevelopment {
                logger.debug("\(message, privacy: .public)")
            } else {
                logger.debug("\(message)")
            }
        case .info:
            if isDevelopment {
                logger.info("\(message, privacy: .public)")
            } else {
                logger.info("\(message)")
            }
        case .warning:
            if isDevelopment {
                logger.warning("\(message, privacy: .public)")
            } else {
                logger.warning("\(message)")
            }
        case .error:
            if isDevelopment {
                logger.error("\(message, privacy: .public)")
            } else {
                logger.error("\(message)")
            }
        case .critical:
            logger.critical("\(message)")
        case .fault:
            logger.fault("\(message)")
        }
    }
}

// MARK: - LoggerTarget
public protocol LoggerTarget {
    var subsystem: String { get }
    var category: StaticString { get }
}

extension AppLogger {
    private static let isSandbox: Bool = {
        guard let path = Bundle.main.appStoreReceiptURL?.path() else {
            return false
        }
        return path.contains("sandboxReceipt")
    }()
}

public extension AppLogger {
    @discardableResult
    static func message(
        _ target: LoggerTarget,
        items: [Any],
        level: SwiftyBeaver.Level,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        let text = items.map {"\($0)"}.joined(separator: " ")
        defer {
            if level == .error {
                errorLogSubject.send(text)
            }
        }
        let message = "[\(target.category)] " + "\(text)"
        SwiftyBeaver.custom(level: level, message: message, file: file, function: function, line: line, context: nil)
        let isSimulator: Bool
#if targetEnvironment(simulator)
        isSimulator = true
#else
        isSimulator = false
#endif
        if isSandbox || isSimulator {
            // 沙盒环境才做 OSLogger 输出
            OSLogger(subsystem: target.subsystem, category: "\(target.category)")
                .send(level, msg: message, file: file, function: function, line: line)
        }
        return text
    }
    
    @discardableResult
    static func message(
        _ target: LoggerTarget,
        _ items: Any ...,
        level: SwiftyBeaver.Level,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> String {
        message(target, items: items, level: level, file: file, function: function, line: line)
    }
}


// 通过日志输出断言（不会被日志文件记录）
public extension AppLogger {
    private static func assert(_ condition: @autoclosure () -> Bool, _ items: Any ..., file: String = #file, function: String = #function, line: Int = #line) {
        guard !condition() else { return }
        let text = items.map {"\($0)"}.joined(separator: " ")
        let message = "\(file):\(line) - \(function)\n \(text)"
        errorLogSubject.send(message)
#if DEBUG
        sleep(3)
        Swift.assertionFailure(text)
#endif
    }
    
    static func assertionFailure(_ items: Any ..., file: String = #file, function: String = #function, line: Int = #line) {
        assert(false, items, file: file, function: function, line: line)
    }
}

public extension AppLogger {
    struct TimePoint: Sendable {
        fileprivate let log: OSLog
        fileprivate let signpostID: OSSignpostID
        fileprivate let subsystem: String
        fileprivate let category: StaticString
        fileprivate let time: CFAbsoluteTime
    }
    
    static func pointBegin(_ target: LoggerTarget, items: [Any]) -> TimePoint {
        let subsystem = target.subsystem
        let category = target.category
        let log = OSLog(subsystem: subsystem, category: .pointsOfInterest)
        let signpostID = OSSignpostID(log: log)
        // Points of Interest
        let text = items.map {"\($0)"}.joined(separator: " ")
        os_signpost(.begin, log: log, name: category, signpostID: signpostID, "%s", text)
        
        // Logger
        let logger = Logger(subsystem: subsystem, category: "\(category)")
        let current = CFAbsoluteTimeGetCurrent()
        let message = "⏱️ BEGIN: [\(category)](at: \(current))" + text
        if isDevelopment {
            logger.debug("\(message, privacy: .public)")
        } else {
            logger.debug("\(message)")
        }
        return .init(
            log: log,
            signpostID: signpostID,
            subsystem: subsystem,
            category: category,
            time: current
        )
    }
    
    static func pointEnd(_ log: TimePoint, items: [Any]) {
        let subsystem = log.subsystem
        let category = log.category
        
        // Points of Interest
        let text = items.map {"\($0)"}.joined(separator: " ")
        os_signpost(.end, log: log.log, name: category, signpostID: log.signpostID, "%s", text)
        
        // Logger
        let logger = Logger(subsystem: subsystem, category: "\(category)")
        let message = "⏱️ END:   [\(category)](cost: \(CFAbsoluteTimeGetCurrent() - log.time)) " + text
        if isDevelopment {
            logger.debug("\(message, privacy: .public)")
        } else {
            logger.debug("\(message)")
        }
    }
    
    static func pointSign(_ target: LoggerTarget, items: [Any]) {
        let subsystem = target.subsystem
        let category = target.category
        
        // Points of Interest
        let log = OSLog(subsystem: subsystem, category: .pointsOfInterest)
        let signpostID = OSSignpostID(log: log)
        let text = items.map {"\($0)"}.joined(separator: " ")
        os_signpost(.event, log: log, name: category, signpostID: signpostID, "%s", text)
        
        // Logger
        let logger = Logger(subsystem: subsystem, category: "\(category)")
        let message = "⏱️ SIGN:  [\(category)](at: \(CFAbsoluteTimeGetCurrent())) " + text
        if isDevelopment {
            logger.debug("\(message, privacy: .public)")
        } else {
            logger.debug("\(message)")
        }
    }
}

public extension AppLogger {
    static func pointBegin(_ target: LoggerTarget, _ items: Any ...) -> TimePoint {
        pointBegin(target, items: items)
    }
    
    static func pointEnd(_ log: TimePoint, _ items: Any ...) {
        pointEnd(log, items: items)
    }
    
    static func pointSign(_ target: LoggerTarget, _ items: Any ...) {
        pointSign(target, items: items)
    }
}

