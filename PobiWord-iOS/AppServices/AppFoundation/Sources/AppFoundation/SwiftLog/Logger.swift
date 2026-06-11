//
//  Logger.swift
//  AppFoundation
//
//  Created by Avery on 2026/4/10.
//

import Foundation
import Logging
import SwiftyBeaver

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

extension Logger {
    @MainActor
    public static func setup(isDevelopment: Bool, logDirectory: String? = nil) {
        // SwiftyBeaver FileDestination
        if let logDirectory {
            cleanExpiredLogs(from: logDirectory)
            makeBeaverFileDestination(logDirectory)
        }

        LoggingSystem.bootstrap { label in
            logHandler(for: label)
        }
    }
    
    private static func logHandler(for label: String) -> any LogHandler {
        let beaverHandler = BeaverLogHandler(label: label)
        let isSimulator: Bool
#if targetEnvironment(simulator)
        isSimulator = true
#else
        isSimulator = false
#endif
        guard AppContext.isSandbox || isSimulator else {
            return beaverHandler
        }
        return MultiplexLogHandler([
            beaverHandler,
            OSLogHandler(label: label)
        ])
        
    }
}

extension Logger {
    private static func makeBeaverFileDestination(_ logDirectory: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = dateFormatter.string(from: .now)
        let filePath = logDirectory.appendingPathComponent(timestamp) as NSString
        let fullPath = filePath.appendingPathExtension("log") ?? "\(filePath).log"

        let file = FileDestination()
        file.format = "\(AppContext.versionInfo) $Dyyyy-MM-dd HH:mm:ss.SSS$d $L [$N.$F:$l] $M"
        file.minLevel = ServerEnvironment.isDevelopment ? .debug : .warning
        file.logFileURL = URL(fileURLWithPath: fullPath)
        SwiftyBeaver.addDestination(file)
    }

    private static func cleanExpiredLogs(from directory: String) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileManager = FileManager.default
                let fileURLs = try fileManager.contentsOfDirectory(
                    at: URL(fileURLWithPath: directory),
                    includingPropertiesForKeys: [.creationDateKey],
                    options: .skipsHiddenFiles
                )
                let expirationTime: TimeInterval = 14 * 24 * 60 * 60
                let now = Date().timeIntervalSince1970
                for fileURL in fileURLs {
                    let resourceValues = try fileURL.resourceValues(forKeys: [.creationDateKey])
                    if let creationDate = resourceValues.creationDate {
                        if now - creationDate.timeIntervalSince1970 >= expirationTime {
                            try fileManager.removeItem(at: fileURL)
                        }
                    }
                }
            } catch {}
        }
    }
}
