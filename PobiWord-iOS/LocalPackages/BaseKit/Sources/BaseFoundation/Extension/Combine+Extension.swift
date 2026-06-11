//
//  File.swift
//  BaseKit
//
//  Created by Avery on 2025/4/26.
//

import Foundation
import Combine

@propertyWrapper
public final class CombineBehavior<T> {
    private let subject: CurrentValueSubject<T, Never>
    
    public var wrappedValue: T {
        didSet {
            subject.send(wrappedValue)
        }
    }
    
    public var projectedValue: AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        self.subject = CurrentValueSubject(wrappedValue)
    }
    
    public init(_ defaultValue: T) {
        self.wrappedValue = defaultValue
        self.subject = CurrentValueSubject(defaultValue)
    }
}

@propertyWrapper
public final class CombineSafeBehavior<T> {
    private var _wrappedValue: T
    private let lock = NSRecursiveLock()
    private let subject: CurrentValueSubject<T, Never>
    
    public var wrappedValue: T {
        get { self.read { $0 } }
        set { self.update { $0 = newValue } }
    }
    
    public var projectedValue: AnyPublisher<T, Never> {
        self.subject.eraseToAnyPublisher()
    }
    
    public init(wrappedValue: T) {
        self._wrappedValue = wrappedValue
        self.subject = CurrentValueSubject(wrappedValue)
    }
    
    public init(_ defaultValue: T) {
        self._wrappedValue = defaultValue
        self.subject = CurrentValueSubject(defaultValue)
    }
    
    @discardableResult
    private func read<U>(_ block: (T) throws -> U) rethrows -> U {
        self.lock.lock()
        defer { self.lock.unlock() }
        return try block(self._wrappedValue)
    }
    
    @discardableResult
    private func update<U>(_ block: (inout T) throws -> U) rethrows -> U {
        self.lock.lock()
        defer { self.lock.unlock() }
        let result = try block(&self._wrappedValue)
        self.subject.send(self._wrappedValue)
        return result
    }
}

@propertyWrapper
public final class CombinePublish<T> {
    public var wrappedValue: PassthroughSubject<T, Never>
    
    public var projectedValue: AnyPublisher<T, Never> {
        wrappedValue.eraseToAnyPublisher()
    }
    
    public init(_ type: T.Type) {
        self.wrappedValue = PassthroughSubject<T, Never>()
    }
}
