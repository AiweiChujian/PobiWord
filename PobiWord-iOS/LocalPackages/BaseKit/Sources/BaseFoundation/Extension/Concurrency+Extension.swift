//
//  File.swift
//  BaseKit
//
//  Created by Avery on 2025/4/26.
//

import Foundation

public extension MainActor {
    nonisolated
    static func safeNonisolated<T>(_ closure: @MainActor () throws -> T) rethrows -> T {
        if Thread.isMainThread {
            try assumeIsolated(closure)
        } else {
            try DispatchQueue.main.sync(execute: closure)
        }
    }
}

public protocol ContinuationType {
    associatedtype T
    associatedtype E: Error
    
    func resume(returning value: T)
    
    func resume(throwing error: E)
    
    func resume(with result: Result<T, E>)
}

extension UnsafeContinuation: ContinuationType {}

extension CheckedContinuation: ContinuationType {}

/**
 只会 resume 一次的 continuation
 - Parameters:
  - asserted: 重复 resume 时是否触发断言 (断言只在 Debug 被判断, 不会影响 Release 版本)
 */
public final class SafeContinuation<Continuation: ContinuationType> {
    private var continuation: Continuation?
    
    public typealias T = Continuation.T
    public typealias E = Continuation.E
    
    public init(_ continuation: Continuation) {
        self.continuation = continuation
    }
    
    private func notResumedContinuation(_ asserted: Bool) -> Continuation? {
        guard let continuation = continuation else {
            assert(!asserted, "重复 Resume 一个 Continuation")
            return nil
        }
        self.continuation = nil
        return continuation
    }
    
    func resume(returning value: T, asserted: Bool = true) {
        notResumedContinuation(asserted)?.resume(returning: value)
    }
    
    func resume(throwing error: E, asserted: Bool = true) {
        notResumedContinuation(asserted)?.resume(throwing: error)
    }
    
    func resume(with result: Result<T, E>, asserted: Bool = true) {
        notResumedContinuation(asserted)?.resume(with: result)
    }
}

public extension SafeContinuation where T == Void {
    func resume(asserted: Bool = true) {
        notResumedContinuation(asserted)?.resume(returning: ())
    }
    
    convenience init(noReturning continuation: Continuation) {
        self.init(continuation)
    }
}
