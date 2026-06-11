//
//  OSLogHandler.swift
//  AppFoundation
//
//  Created by Avery on 2026/4/10.
//

import Foundation
import Logging
import OSLog
import Combine

struct OSLogHandler: LogHandler {
    typealias Logger = Logging.Logger
    
    static let errorLogSubject = PassthroughSubject<String, Never>()
    
    private let osLogger: os.Logger
    
    init(label: String) {
        self.osLogger = os.Logger(subsystem: AppContext.appName, category: label)
    }

    var metadata: Logger.Metadata = [:]
    var logLevel: Logger.Level = .debug

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }
    
    private func prefix(for level: Logger.Level) -> String {
        switch level {
        case .error, .critical:
            return "❌"
        case .warning:
            return "⚠️"
        case .notice, .info:
            return "💡"
        case .trace, .debug:
            return ""
        }
    }

    func log(event: LogEvent) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = dateFormatter.string(from: .now)
        
        let prefix = prefix(for: event.level)

        let formatted = "\(timestamp) [\(event.function):\(event.line)]\(prefix): \(event.message)"

        switch event.level {
        case .trace:
            osLogger.trace("\(formatted)")
        case .debug:
            osLogger.debug("\(formatted, privacy: .public)")
        case .info, .notice:
            osLogger.info("\(formatted, privacy: .public)")
        case .warning:
            osLogger.warning("\(formatted, privacy: .public)")
        case .error, .critical:
            osLogger.error("\(formatted, privacy: .public)")
            let message = "\(event.message)"
            Self.errorLogSubject.send(message)
#if DEBUG
            DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
                assertionFailure(message)
            }
#endif
        }
    }
}
