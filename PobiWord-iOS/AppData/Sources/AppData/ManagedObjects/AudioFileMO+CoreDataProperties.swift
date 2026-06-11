//
//  AudioFileMO+CoreDataProperties.swift
//  
//
//  Created by Avery on 2025/10/30.
//
//

import Foundation
import CoreData


public typealias AudioFileMOCoreDataPropertiesSet = NSSet

extension AudioFileMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioFileMO> {
        return NSFetchRequest<AudioFileMO>(entityName: "AudioFileMO")
    }
    
}


