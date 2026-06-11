//
//  PronunciationMO+CoreDataProperties.swift
//  
//
//  Created by Avery on 2025/10/30.
//
//

import Foundation
import CoreData


public typealias PronunciationMOCoreDataPropertiesSet = NSSet

extension PronunciationMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PronunciationMO> {
        return NSFetchRequest<PronunciationMO>(entityName: "PronunciationMO")
    }

    @NSManaged public var ipa: String?
    @NSManaged public var nation: String?
    @NSManaged public var audioFile: AudioFileMO?

}
