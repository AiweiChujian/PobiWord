//
//  PerceptibleCoreData.swift
//  MVVMReduxDemo
//
//  Created by Avery on 2024/9/11.
//

import Foundation
import CoreData
import SwiftUI

protocol ObservableBridgeProtocol: NSManagedObject {
    func access<T>(keyPath: KeyPath<Self, T>, fileID: StaticString, filePath: StaticString, line: UInt, column: UInt)
    
    func withMutation<Member, MutationResult>(keyPath: KeyPath<Self, Member>, _ mutation: () throws -> MutationResult) rethrows -> MutationResult
}

extension ObservableBridgeProtocol {
    func bridge_access<U,T>(keyPath: KeyPath<U, T>,fileID: StaticString, filePath: StaticString, line: UInt, column: UInt) {
        guard let keyPath = keyPath as? KeyPath<Self, T> else {
            assertionFailure("\(self.self) needs to conform `ObservableBridgeProtocol`")
            return
        }
        access(keyPath: keyPath, fileID: fileID, filePath: filePath, line: line, column: column)
    }
    
    func bridge_withMutation<U,Member, MutationResult>(keyPath: KeyPath<U, Member>, _ mutation: () throws -> MutationResult) rethrows {
        guard let keyPath = keyPath as? KeyPath<Self, Member> else {
            assertionFailure("\(self.self) needs to conform `ObservableBridgeProtocol`")
            return
        }
        let _ = try withMutation(keyPath: keyPath, mutation)
    }
    
    func safeWithMutation<Member, MutationResult>(keyPath: KeyPath<Self, Member>, _ mutation: () throws -> MutationResult) rethrows -> MutationResult {
        try withMutation(keyPath: keyPath, mutation)
    }
}

public protocol ObservableManagedObject: NSManagedObject {
    
}

public extension ObservableManagedObject {
    fileprivate var coreDataClassName: String {
        return NSStringFromClass(Self.self)
    }
    
    /// 一般在数组中更新了元素时需要手动触发更新
    func changeMutation<T>(keyPath: KeyPath<Self, T>) {
        let keyString = NSExpression(forKeyPath: keyPath).keyPath
        changeMutation(key: keyString)
    }
    
    fileprivate func addKeyPaths<T>(keyPath: KeyPath<Self, T>)  {
        guard !isDeleted else { return }
        let item = ObservableActionStore.share.getItem(classname: coreDataClassName, target: self)
        let keyString = NSExpression(forKeyPath: keyPath).keyPath
        
        if item.actionInfo[keyString] == nil {
            let action: (any ObservableManagedObject) -> Void = { obj in
                if let target = obj as? (any ObservableBridgeProtocol) {
                    target.bridge_withMutation(keyPath: keyPath) {
                        
                    }
                }
            }
            item.actionInfo[keyString] = action
        }
    }
    
    func deInitObj() {
        let item = ObservableActionStore.share.getItem(classname: coreDataClassName, target: self)
        item.actionInfo.forEach { (key: String, value: (any ObservableManagedObject) -> Void) in
            value(self)
        }
    }
    
    func changeMutation(key: String) {
        let item = ObservableActionStore.share.getItem(classname: coreDataClassName, target: self)
        if let action = item.actionInfo[key] {
            action(self)
        }
    }
    
    subscript<T>(keyPath: KeyPath<Self, T>) -> T {
        get {
            get(keyPath: keyPath)
        }
        set {
            set(keyPath: keyPath, newValue: newValue)
        }
    }
    
    func set<T>(keyPath: KeyPath<Self, T>, newValue: T) {
        addKeyPaths(keyPath: keyPath)
        let keyString = NSExpression(forKeyPath: keyPath).keyPath
        setValue(newValue, forKey: keyString)
    }
    
    func get<T>(keyPath: KeyPath<Self, T>) -> T {
        if let target = self as? (any ObservableBridgeProtocol) {
            target.bridge_access(keyPath: keyPath, fileID: #fileID, filePath: #filePath, line: #line, column: #column)
        }
        addKeyPaths(keyPath: keyPath)
        return self[keyPath: keyPath]
    }
}

fileprivate class ObservableActionStore {
    static let share = ObservableActionStore()
    class Item {
        let name: String
        private let lock: os_unfair_lock_t
        private var _actionInfo: [String: (any ObservableManagedObject) -> Void] = [:]
        init(name: String) {
            self.name = name
            self.lock = .allocate(capacity: 1)
            lock.initialize(to: os_unfair_lock())
        }
        
        var actionInfo: [String: (any ObservableManagedObject) -> Void] {
            get {
                os_unfair_lock_lock(lock)
                let info = _actionInfo
                defer { os_unfair_lock_unlock(lock) }
                return info
            }
            set {
                os_unfair_lock_lock(lock); defer { os_unfair_lock_unlock(lock) }
                _actionInfo = newValue
            }
        }
    }
    var items = [Item]()
    private let lock: os_unfair_lock_t
    
    init() {
        lock = .allocate(capacity: 1)
        lock.initialize(to: os_unfair_lock())
    }
    
    func getItem(classname: String, target: AnyObject) -> Item {
        if let item = items.first(where: { $0.name == classname }) {
            return item
        } else {
            os_unfair_lock_lock(lock)
            defer { os_unfair_lock_unlock(lock) }
            let item = Item(name: classname)
            items.append(item)
            return item
        }
    }
}

@dynamicMemberLookup
public protocol ObservableContainer: AnyObject, Equatable {
    associatedtype ManagedObject: ObservableManagedObject
    var managedObj: ManagedObject { get }
}

public extension ObservableContainer {
    subscript<T>(dynamicMember keyPath: KeyPath<ManagedObject, T>) -> T {
        get {
            return managedObj.get(keyPath: keyPath)
        }
        set {
            managedObj.set(keyPath: keyPath, newValue: newValue)
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.managedObj == rhs.managedObj
    }
}
