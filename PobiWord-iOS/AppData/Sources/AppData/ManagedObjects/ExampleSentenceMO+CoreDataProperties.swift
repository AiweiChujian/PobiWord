//
//  ExampleSentenceMO+CoreDataProperties.swift
//  
//
//  Created by Avery on 2025/10/30.
//
//

import Foundation
import CoreData


public typealias ExampleSentenceMOCoreDataPropertiesSet = NSSet

extension ExampleSentenceMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExampleSentenceMO> {
        return NSFetchRequest<ExampleSentenceMO>(entityName: "ExampleSentenceMO")
    }

    @NSManaged public var content: String
    @NSManaged public var audioFile: AudioFileMO?

}
