//
//  LearningWordMO+CoreDataProperties.swift
//  
//
//  Created by Avery on 2025/10/30.
//
//

import Foundation
import CoreData


public typealias LearningWordMOCoreDataPropertiesSet = NSSet

extension LearningWordMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LearningWordMO> {
        return NSFetchRequest<LearningWordMO>(entityName: "LearningWordMO")
    }

    @NSManaged public var mistackCount: Int64
    @NSManaged public var learningScore: Int64
    @NSManaged public var trunIndex: Int64
    @NSManaged public var word: WordMO
    @NSManaged public var learnPlan: WordPlanMO

}
