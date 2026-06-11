//
//  File.swift
//  AppUI
//
//  Created by Avery on 2025/4/29.
//

import Foundation
import SwiftUI

public extension Text {
    func fontSansitaOne(_ color: Color, size: CGFloat) -> Text {
        foregroundStyle(color)
            .font(.customFont(.sansitaOne, size: size))
    }
}
