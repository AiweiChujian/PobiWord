//
//  File.swift
//  BaseKit
//
//  Created by Avery on 2025/7/1.
//

import Foundation

public extension Locale {
    static var currentLanguageCode: String? {
        if let language = Locale.preferredLanguages.first {
            return Locale(identifier: language).currentLanguageCode
        }
        return Locale.current.currentLanguageCode
    }
    
    static var currentRegionCode: String? {
        if #available(iOS 16, *) {
            return Locale.current.language.region?.identifier
        } else {
            return Locale.current.regionCode
        }
    }
    
    var currentLanguageCode: String? {
        var script: String?
        var languageCode: String?
        if #available(iOS 16, *) {
            script = language.script?.identifier
            languageCode = language.languageCode?.identifier
        } else {
            script = scriptCode
            languageCode = self.languageCode
        }
        if let languageCode = languageCode {
            if let script = script {
                if self.identifier.contains(script) {
                    return "\(languageCode)-\(script)"
                } else {
                    return languageCode
                }
            } else {
                return languageCode
            }
        }
        return nil
    }
}
