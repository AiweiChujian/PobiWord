//
//  EKWindow.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 4/19/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import UIKit

extension UIWindow {
    static var availableWindowScene: UIWindowScene? {
        if let scene = UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}).first as? UIWindowScene {
            return scene
        }
        if let window = UIApplication.shared.delegate?.window, let window = window {
            return window.windowScene
        }
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene}).first?.windows.first else {
            return nil
        }
        return window.windowScene
    }
    
    static var mainWindow: UIWindow {
        if let window = UIApplication.shared.delegate?.window, let window = window {
            return window
        }
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene}).first?.windows.first else {
            assertionFailure("Not set first window")
            return .init()
        }
        return window
    }
    
    static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .filter { $0.isKeyWindow }
            .last
    }
}

class EKWindow: UIWindow {
    
    var isAbleToReceiveTouches = false
    
    init?(with rootVC: UIViewController) {
        // TODO: Patched to support SwiftUI out of the box but should require attendance
        guard let scene = UIWindow.availableWindowScene else {
            return nil
        }
        super.init(windowScene: scene)
        backgroundColor = .clear
        rootViewController = rootVC
        accessibilityViewIsModal = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isAbleToReceiveTouches {
            return super.hitTest(point, with: event)
        }
        
        guard let rootVC = EKWindowProvider.shared.rootVC else {
            return nil
        }
        
        if let view = rootVC.view.hitTest(point, with: event) {
            return view
        }
        
        return nil
    }
}
