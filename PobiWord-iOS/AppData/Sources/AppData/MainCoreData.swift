//
//  File.swift
//  AppData
//
//  Created by Avery on 2025/4/26.
//

import Foundation
import CoreData
import BaseFoundation
import Combine

@MainActor
public enum MainCoreData {
    public static let persistentContainer: NSPersistentContainer = {
        guard let modelURL = Bundle.module.url(forResource:"CoreModels", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL)
        else { return NSPersistentContainer(name: "CoreModels") }
        let container = NSPersistentContainer(name:"CoreModels", managedObjectModel:model)
        
        // 配置Core Data自动迁移选项
        // 当数据模型发生变化时，这些设置允许Core Data尝试自动迁移用户数据
        // shouldMigrateStoreAutomatically: 启用自动迁移功能
        // shouldInferMappingModelAutomatically: 允许Core Data在没有显式映射模型的情况下推断映射关系
        if let storeDescription = container.persistentStoreDescriptions.first {
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.shouldInferMappingModelAutomatically = true
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // 迁移失败时记录错误信息，但不删除用户数据
                // 对于复杂的模型变更，可能需要创建显式的映射模型
                print("Core Data 迁移失败: \(error), \(error.userInfo)")
                assertionFailure("\(Self.self) 模型迁移失败，请创建正确的映射模型: \(error), \(error.userInfo)")
            } else {
                print(storeDescription.url?.absoluteString ?? "")
            }
        })
//        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy // 使用新值并保留旧值
        container.viewContext.mergePolicy = NSRollbackMergePolicy // 保留旧值
        // 启用自动合并：当父上下文发生变化时，自动合并到视图上下文
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
}

extension MainCoreData: @preconcurrency CoreDataStack {
    public static var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
}

extension MainCoreData {
    // 用于延迟保存操作的主题
    private static let synchronizeSubject = PassthroughSubject<Void, Never>()
    
    private static var throttleCancellable: Cancellable?
    
    // 如果需要，开始观察同步事件
    private static func observeSynchronizeIfNeed() {
        guard throttleCancellable == nil else { return }
        throttleCancellable = synchronizeSubject
            // 节流操作：250毫秒内的多次保存请求只执行最后一次
            .throttle(for: .milliseconds(250), scheduler: DispatchQueue.main, latest: true)
            .sink { _ in
                saveAtOnce()
            }
    }
}

extension MainCoreData {
    // 延迟同步方法：将多次保存操作合并为一次执行，提高性能
    public static func synchronize() {
        observeSynchronizeIfNeed()
        synchronizeSubject.send(())
    }
}

