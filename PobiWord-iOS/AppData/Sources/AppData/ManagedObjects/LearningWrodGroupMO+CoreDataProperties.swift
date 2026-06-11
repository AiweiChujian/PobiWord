//
//  LearningWrodGroupMO+CoreDataProperties.swift
//  
//
//  Created by Avery on 2025/10/30.
//
//

import Foundation
import CoreData


public typealias LearningWrodGroupMOCoreDataPropertiesSet = NSSet

extension LearningWrodGroupMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LearningWrodGroupMO> {
        return NSFetchRequest<LearningWrodGroupMO>(entityName: "LearningWrodGroupMO")
    }

    @NSManaged public var learnWords: [LearningWordMO]
    @NSManaged public var reviewWords: [LearningWordMO]
    @NSManaged public var learnPlan: WordLearnPlanMO

}

// MARK: Generated accessors for learnWords
extension LearningWrodGroupMO {

    @objc(addLearnWordsObject:)
    @NSManaged public func addToLearnWords(_ value: LearningWordMO)

    @objc(removeLearnWordsObject:)
    @NSManaged public func removeFromLearnWords(_ value: LearningWordMO)

    @objc(addLearnWords:)
    @NSManaged public func addToLearnWords(_ values: [LearningWordMO])

    @objc(removeLearnWords:)
    @NSManaged public func removeFromLearnWords(_ values: [LearningWordMO])

}

// MARK: Generated accessors for reviewWords
extension LearningWrodGroupMO {

    @objc(addReviewWordsObject:)
    @NSManaged public func addToReviewWords(_ value: LearningWordMO)

    @objc(removeReviewWordsObject:)
    @NSManaged public func removeFromReviewWords(_ value: LearningWordMO)

    @objc(addReviewWords:)
    @NSManaged public func addToReviewWords(_ values: [LearningWordMO])

    @objc(removeReviewWords:)
    @NSManaged public func removeFromReviewWords(_ values: [LearningWordMO])

}
