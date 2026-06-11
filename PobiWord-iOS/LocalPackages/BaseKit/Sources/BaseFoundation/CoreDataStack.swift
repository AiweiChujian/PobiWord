//
//  File.swift
//  BaseKit
//
//  Created by Avery on 2025/4/26.
//

import Foundation
import CoreData

public protocol CoreDataStack {
    static var context: NSManagedObjectContext { get }
}

public extension CoreDataStack {
    static func saveAtOnce() {
        do {
            try throwableSave()
        } catch {
            assertionFailure("CoreData 保存抛错: \(error.localizedDescription)")
        }
    }
    
    static func throwableSave() throws {
        let context = context
        guard context.hasChanges else {
            return
        }
        try context.save()
    }
}

// MARK: 增
public extension CoreDataStack {
    @discardableResult
    static func create<T: NSManagedObject>(type: T.Type = T.self, builder: (T) -> Void = { _ in }) -> T {
        let item = T(context: context)
        builder(item)
        return item
    }
}

// MARK: 改
public extension CoreDataStack {
    static func modify(execute: () -> Void) {
        execute()
        saveAtOnce()
    }
}

// MARK: 删
public extension CoreDataStack {
    static func delete<T: NSManagedObject>(_ item: T) {
        context.delete(item)
    }
    
    static func delete<T: NSManagedObject>(_ type: T.Type, with predicate: NSPredicate?) throws {
        let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
        fetchRequest.predicate = predicate
        let results = try context.fetch(fetchRequest)
        results.forEach { context.delete($0)}
    }
    
    static func deleteAll<T: NSManagedObject>(_ type: T.Type, needSync: Bool = true) throws {
        try delete(type, with: nil)
    }
}

// MARK: 查
public extension CoreDataStack {
    static func fetch<T: NSManagedObject>(
        type: T.Type = T.self,
        request: NSFetchRequest<T>
    ) throws -> [T] {
        try context.fetch(request)
    }
    
    static func find<T: NSManagedObject>(
        type: T.Type = T.self,
        predicate: NSPredicate?,
        sortDescriptors: [NSSortDescriptor]? = nil,
        fetchLimit: Int? = nil
    ) throws -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        if let fetchLimit = fetchLimit {
            fetchRequest.fetchLimit = fetchLimit
        }
        return try fetch(request: fetchRequest)
    }
    
    static func findOne<T: NSManagedObject>(
        type: T.Type = T.self,
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> T? {
        try find(predicate: predicate, sortDescriptors: sortDescriptors, fetchLimit: 1).first
    }
    
    static func findAll<T: NSManagedObject>(
        type: T.Type = T.self,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> [T] {
        try find(predicate: nil, sortDescriptors: sortDescriptors)
    }
}

