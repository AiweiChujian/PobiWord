//
//  File.swift
//  BaseKit
//
//  Created by Avery on 2025/7/1.
//

import Foundation
import NaturalLanguage

public extension String {
    static func textToLanguageCode(_ string: String?) -> String {
        func local() -> [String] {
            let lans = Locale.preferredLanguages
            if let region = Locale.current.region?.identifier {
                return lans.map {
                    $0.replacingOccurrences(of: "-\(region)", with: "")
                } + ["en"]
            } else {
                return lans + ["en"]
            }
        }
        func language(astring: String) -> String? {
            // 分词
            let tokenizer: NLTokenizer
            if astring.count > 100 {
                tokenizer = NLTokenizer(unit: .sentence)
            } else {
                tokenizer = NLTokenizer(unit: .word)
            }
            tokenizer.string = astring
            var languages: [String: Int] = [:]
            tokenizer.enumerateTokens(in: astring.startIndex..<astring.endIndex) { tokenRange, _ in
                // print(text[tokenRange])
                let string = String(astring[tokenRange])
                if let lang = NLLanguageRecognizer.dominantLanguage(for: string)?.rawValue {
                    if let oldValue = languages[lang] {
                        languages[lang] = oldValue + 1
                    } else {
                        languages[lang] = 1
                    }
                }
                return true
            }
            let results = languages.sorted { tuple1, tuple2 in
                tuple1.value > tuple2.value
            }
            return results.first?.key
        }
        let localLans = local()
        if let string = string, let lan = language(astring: string) {
            var newlan = lan
            if lan.count > 1 {
                let startIndex = lan.startIndex
                let endIndex = lan.index(startIndex, offsetBy: 2)
                let firstTwoCharacters = lan[startIndex..<endIndex]
                newlan = String(firstTwoCharacters)
            }
            if let firstCode = localLans.first(where: {
                !$0.contains(newlan)
            }) {
                return firstCode
            }
        }
        return localLans.first!
    }
}
