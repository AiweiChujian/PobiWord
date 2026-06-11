//
//  File.swift
//  AppLog
//
//  Created by Avery on 2025/7/28.
//

import Foundation

// MARK: - Time Log
public struct AppCostTarget: LoggerTarget {
    public var subsystem: String
    
    public var category: StaticString
    
    public init(_ category: StaticString, subsystem: String = "com.appDemo.timeLog") {
        assertionFailure("设置 subsystem")
        self.subsystem = subsystem
        self.category = category
    }
    
    public static var cost: Self {
        .init("cost")
    }
}

public extension AppLogger {
    static func start(_ timeLog: AppCostTarget, _ items: Any ...) -> TimePoint {
        pointBegin(timeLog, items: items)
    }
    
    static func end(_ log: TimePoint, _ items: Any ...) {
        pointEnd(log, items: items)
    }
    
    static func sign(_ timeLog: AppCostTarget, _ items: Any ...) {
        pointSign(timeLog, items: items)
    }
}
