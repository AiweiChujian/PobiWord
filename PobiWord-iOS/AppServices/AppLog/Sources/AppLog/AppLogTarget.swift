// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct AppLogTarget: LoggerTarget {
    public var subsystem: String
    
    public var category: StaticString
    
    public init(_ category: StaticString, subsystem: String = "com.appDemo.log") {
        assertionFailure("设置 subsystem")
        self.subsystem = subsystem
        self.category = category
    }
}

public extension AppLogTarget {
    static var log: Self {
        .init("log")
    }
}

public extension AppLogger {
    static func verbose(_ log: AppLogTarget, _ items: Any ..., file: String = #file, function: String = #function, line: Int = #line) {
        message(log, items: items, level: .verbose, file: file, function: function, line: line)
    }
    
    static func debug(_ log: AppLogTarget, _ items: Any ..., file: String = #file, function: String = #function, line: Int = #line) {
        message(log, items: items, level: .debug, file: file, function: function, line: line)
    }
    
    static func info(_ log: AppLogTarget, _ items: Any ..., file: String = #file, function: String = #function, line: Int = #line) {
        message(log, items: items, level: .info, file: file, function: function, line: line)
    }
    
    static func warning(_ log: AppLogTarget, _ items: Any ..., file: String = #file, function: String = #function, line: Int = #line) {
        message(log, items: items, level: .warning, file: file, function: function, line: line)
    }
    
    static func error(_ log: AppLogTarget, _ items: Any ..., file: String = #file, function: String = #function, line: Int = #line) {
        let content = message(log, items: items, level: .error, file: file, function: function, line: line)
        // 调试时, 断言错误, 但给日志的保存留足时间
#if DEBUG
        sleep(3)
        assertionFailure(content)
#endif
    }
}
