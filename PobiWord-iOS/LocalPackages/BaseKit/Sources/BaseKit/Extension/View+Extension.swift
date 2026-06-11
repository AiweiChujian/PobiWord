// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public extension View {
    func border(_ color: Color, width: CGFloat, cornerRadius: CGFloat) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .inset(by: width/2)
                .stroke(color, lineWidth: width)
        )
    }
    
    func contentClipShape<S>(_ shape: S) -> some View where S : Shape {
        clipShape(shape).contentShape(shape)
    }
}
    

