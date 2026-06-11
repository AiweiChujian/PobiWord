//
//  WordLearnPlanMO+CoreDataProperties.swift
//  
//
//  Created by Avery on 2025/10/30.
//
//

import Foundation
import CoreData


public typealias WordLearnPlanMOCoreDataPropertiesSet = NSSet

extension WordLearnPlanMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordLearnPlanMO> {
        return NSFetchRequest<WordLearnPlanMO>(entityName: "WordLearnPlanMO")
    }

    @NSManaged public var title: String
    @NSManaged public var preferredLearnCount: Int64
    @NSManaged public var selectedDate: Date?
    @NSManaged public var nextTurnIndex: Int64
    @NSManaged public var lastFinishTurnRaw: Int16
    @NSManaged public var words: [LearningWordMO]
    @NSManaged public var learningGroup: LearningWrodGroupMO?

}

// MARK: Generated accessors for words
extension WordLearnPlanMO {

    @objc(insertObject:inWordsAtIndex:)
    @NSManaged public func insertIntoWords(_ value: LearningWordMO, at idx: Int)

    @objc(removeObjectFromWordsAtIndex:)
    @NSManaged public func removeFromWords(at idx: Int)

    @objc(insertWords:atIndexes:)
    @NSManaged public func insertIntoWords(_ values: [LearningWordMO], at indexes: NSIndexSet)

    @objc(removeWordsAtIndexes:)
    @NSManaged public func removeFromWords(at indexes: NSIndexSet)

    @objc(replaceObjectInWordsAtIndex:withObject:)
    @NSManaged public func replaceWords(at idx: Int, with value: LearningWordMO)

    @objc(replaceWordsAtIndexes:withWords:)
    @NSManaged public func replaceWords(at indexes: NSIndexSet, with values: [LearningWordMO])

    @objc(addWordsObject:)
    @NSManaged public func addToWords(_ value: LearningWordMO)

    @objc(removeWordsObject:)
    @NSManaged public func removeFromWords(_ value: LearningWordMO)

    @objc(addWords:)
    @NSManaged public func addToWords(_ values: [LearningWordMO])

    @objc(removeWords:)
    @NSManaged public func removeFromWords(_ values: [LearningWordMO])

}
