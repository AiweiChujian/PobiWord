//
//  WordLearningGroupMO+CoreDataProperties.swift
//  
//
//  Created by Avery on 2025/10/30.
//
//

import Foundation
import CoreData


public typealias WordLearningGroupMOCoreDataPropertiesSet = NSSet

extension WordLearningGroupMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordLearningGroupMO> {
        return NSFetchRequest<WordLearningGroupMO>(entityName: "WordLearningGroupMO")
    }

    @NSManaged public var learnWords: [LearningWordMO]
    @NSManaged public var reviewWords: [LearningWordMO]
    @NSManaged public var learnPlan: WordPlanMO

}

// MARK: Generated accessors for learnWords
extension WordLearningGroupMO {

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
extension WordLearningGroupMO {

    @objc(addReviewWordsObject:)
    @NSManaged public func addToReviewWords(_ value: LearningWordMO)

    @objc(removeReviewWordsObject:)
    @NSManaged public func removeFromReviewWords(_ value: LearningWordMO)

    @objc(addReviewWords:)
    @NSManaged public func addToReviewWords(_ values: [LearningWordMO])

    @objc(removeReviewWords:)
    @NSManaged public func removeFromReviewWords(_ values: [LearningWordMO])

}
