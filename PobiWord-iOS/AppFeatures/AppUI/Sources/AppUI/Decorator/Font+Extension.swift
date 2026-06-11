//
//  File.swift
//  AppUI
//
//  Created by Avery on 2025/4/29.
//

import Foundation
import SwiftUI

extension Font {
    public enum CustomFont: String, CaseIterable {
        case sansitaOne = "SansitaOne"

        var fontExtension: String { 
            "ttf" 
        }
    }
}

extension Font {
    static func registerCustomFont() {
        CustomFont.allCases.forEach { register($0) }
    }
    
    private static func register(_ font: CustomFont) {
        guard let fontURL = Bundle.module.url(forResource: font.rawValue, withExtension: font.fontExtension) else {
            assertionFailure("字体 \(font.rawValue) 文件没找到")
            return
        }
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
        if let error = error?.takeUnretainedValue() {
            assertionFailure("字体 \(font.rawValue) 注册失败：\(error)")
        }
    }

    public static func customFont(_ font: CustomFont, size: CGFloat) -> Font {
        .custom(font.rawValue, size: size)
    }
}
