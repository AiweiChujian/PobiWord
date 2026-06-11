//
//  File.swift
//  AppUI
//
//  Created by Avery on 2025/5/8.
//

import Foundation
import SwiftUI

public struct NoEffectButtonStyle: ButtonStyle {
    public init() {
        
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

public extension ButtonStyle where Self == NoEffectButtonStyle {
    static var noEffect: Self {
        .init()
    }
}
