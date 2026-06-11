//
//  TimeCost.swift
//  AppFoundation
//
//  Created by Avery on 2026/4/10.
//

import Foundation
import OSLog
import os.signpost
import Logging

public struct TimeCost: Sendable {
    public let log: OSLog
    public let signpostID: OSSignpostID
    public let subsystem: String
    public let name: StaticString
    public let time: CFAbsoluteTime
}

public struct TimeCostTarget {
    public var subsystem: String
    public var name: StaticString
    
    public init(_ name: StaticString, subsystem: String = AppContext.appName) {
        self.subsystem = subsystem
        self.name = name
    }
    
    public static var cost: Self {
        .init("cost")
    }
}

extension TimeCost {
    static let logger: Logging.Logger = {
        var logger = Logger(label: "TimeCost")
        logger.logLevel = .debug
        return logger
    }()
    
    
    static func begin(_ target: TimeCostTarget, items: [Any]) -> TimeCost {
        let subsystem = target.subsystem
        let name = target.name
        let log = OSLog(subsystem: subsystem, category: .pointsOfInterest)
        let signpostID = OSSignpostID(log: log)
        let text = items.map { "\($0)" }.joined(separator: " ")
        os_signpost(.begin, log: log, name: name, signpostID: signpostID, "%s", text)

        let current = CFAbsoluteTimeGetCurrent()
        let message = "⏱️ BEGIN: [\(name)](at: \(current)) " + text
        logger.debug("\(message)")
        return TimeCost(
            log: log,
            signpostID: signpostID,
            subsystem: subsystem,
            name: name,
            time: current
        )
    }

    static func end(_ point: TimeCost, items: [Any]) {
        let name = point.name
        let text = items.map { "\($0)" }.joined(separator: " ")
        os_signpost(.end, log: point.log, name: name, signpostID: point.signpostID, "%s", text)

        let cost = CFAbsoluteTimeGetCurrent() - point.time
        let message = "⏱️ END:   [\(name)](cost: \(cost)) " + text
        logger.debug("\(message)")
    }

    static func sign(_ target: TimeCostTarget, items: [Any]) {
        let subsystem = target.subsystem
        let name = target.name
        let log = OSLog(subsystem: subsystem, category: .pointsOfInterest)
        let signpostID = OSSignpostID(log: log)
        let text = items.map { "\($0)" }.joined(separator: " ")
        os_signpost(.event, log: log, name: name, signpostID: signpostID, "%s", text)

        let message = "⏱️ SIGN:  [\(name)](at: \(CFAbsoluteTimeGetCurrent())) " + text
        logger.debug("\(message)")
    }
}

public extension TimeCost {
    static func begin(_ target: TimeCostTarget, _ items: Any ...) -> TimeCost {
        begin(target, items: items)
    }
    
    static func end(_ point: TimeCost, _ items: Any ...) {
        end(point, items: items)
    }
    
    static func sign(_ target: TimeCostTarget, _ items: Any ...) {
        sign(target, items: items)
    }
}
