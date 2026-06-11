//
//  File.swift
//  BaseKit
//
//  Created by Avery on 2025/4/27.
//

import Foundation
import SwiftUI

public protocol ColorValueType {
    var rgbCodeValue: UInt64 { get }
    var rgbaCodeValue: UInt64 { get }
}

extension Int: ColorValueType {
    public var rgbCodeValue: UInt64 {
        UInt64(self)
    }
    
    public var rgbaCodeValue: UInt64 {
        UInt64(self)
    }
}

extension String: ColorValueType {
    private var scanHexInt64: UInt64 {
        var hex = self
        if hex.hasPrefix("#") {
            hex = String(hex[hex.index(after: hex.startIndex)...])
        }
        let scanner = Scanner(string: hex)
        var codeValue: UInt64 = 0
        scanner.scanHexInt64(&codeValue)
        return codeValue
    }
    
    public var rgbCodeValue: UInt64 {
        scanHexInt64
    }
    
    public var rgbaCodeValue: UInt64 {
        scanHexInt64
    }
}

public extension Color {
    init(rgb: ColorValueType, alpha: CGFloat = 1) {
        let rgbCodeValue = rgb.rgbCodeValue
        self.init(
            red: Double((rgbCodeValue & 0xFF0000) >> 16)/255,
            green: Double((rgbCodeValue & 0xFF00) >> 8)/255,
            blue: Double(rgbCodeValue & 0xFF)/255,
            opacity: alpha
        )
    }
    
    init(rgba: ColorValueType) {
        let rgbaCodeValue = rgba.rgbaCodeValue
        self.init(
            red: Double((rgbaCodeValue & 0xFF000000) >> 24)/255,
            green: Double((rgbaCodeValue & 0xFF0000) >> 16)/255,
            blue: Double((rgbaCodeValue & 0xFF00) >> 8)/255,
            opacity: CGFloat(rgbaCodeValue & 0xFF)/255
        )
    }
}
