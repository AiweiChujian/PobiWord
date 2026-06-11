//
//  WordMO+CoreDataProperties.swift
//  
//
//  Created by Avery on 2025/10/30.
//
//

import Foundation
import CoreData


public typealias WordMOCoreDataPropertiesSet = NSSet

extension WordMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordMO> {
        return NSFetchRequest<WordMO>(entityName: "WordMO")
    }

    @NSManaged public var symbol: String
    @NSManaged public var isMastered: Bool
    @NSManaged public var content: String?
    @NSManaged public var mistakeCount: Int64
    @NSManaged public var baseFrom: WordMO?

}
