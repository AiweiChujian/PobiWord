//
//  VisualEffectView_SwiftUI.swift
//  VisualEffectView
//
//  Created by 朱浩宇 on 2023/5/10.
//  Copyright © 2023 Lasha Efremidze. All rights reserved.
//

import SwiftUI

public extension View {
    func blurEffect(color: Color = .black, radius: CGFloat = 50, alpha: CGFloat = 0.3, scale: CGFloat = 1, blurStyle: UIBlurEffect.Style = .regular) -> some View {
        background {
            BlurVisualEffect(colorTint: color, colorTintAlpha: alpha, blurRadius: radius, scale: scale, blurStyle: blurStyle)
        }
    }
}

public struct BlurVisualEffect: UIViewRepresentable {
    let colorTint: Color?
    let colorTintAlpha: CGFloat
    let blurRadius: CGFloat
    let scale: CGFloat
    let blurStyle: UIBlurEffect.Style
    
    public init(colorTint: Color = .black, colorTintAlpha: CGFloat = 0.3, blurRadius: CGFloat = 50, scale: CGFloat = 1, blurStyle: UIBlurEffect.Style = .regular) {
        self.colorTint = colorTint
        self.colorTintAlpha = colorTintAlpha
        self.blurRadius = blurRadius
        self.scale = scale
        self.blurStyle = blurStyle
    }
    
    public func makeUIView(context: Context) -> VisualEffectView {
        let view = VisualEffectView(effect: UIBlurEffect(style: blurStyle))
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if let colorTint {
            view.colorTint = UIColor(colorTint)
        }
        view.colorTintAlpha = colorTintAlpha
        view.blurRadius = blurRadius
        view.scale = scale
        
        return view
    }
    
    public func updateUIView(_ uiView: VisualEffectView, context: Context) {
        if let colorTint {
            uiView.colorTint = UIColor(colorTint)
        }
        uiView.colorTintAlpha = colorTintAlpha
        uiView.blurRadius = blurRadius
        uiView.scale = scale
    }
}
