//
//  BeaverLogHandler.swift
//  AppFoundation
//
//  Created by Avery on 2026/4/10.
//

import Foundation
import Logging
import SwiftyBeaver

struct BeaverLogHandler: LogHandler{
    let label: String
    var metadata: Logger.Metadata = [:]
    var logLevel: Logger.Level = .trace

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    func log(event: LogEvent) {
        let beaverLevel = Self.mapLevel(event.level)
        SwiftyBeaver.custom(
            level: beaverLevel,
            message: "\(label) → \(event.message)",
            file: event.file,
            function: event.function,
            line: Int(event.line),
            context: event.metadata
        )
    }

    private static func mapLevel(_ level: Logger.Level) -> SwiftyBeaver.Level {
        switch level {
        case .trace:
            return .verbose
        case .debug:
            return .debug
        case .info:
            return .info
        case .notice, .warning:
            return .warning
        case .error:
            return .error
        case .critical:
            return .critical
        }
    }
}
