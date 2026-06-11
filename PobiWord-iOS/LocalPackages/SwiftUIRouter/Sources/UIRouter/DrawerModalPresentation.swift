//
//  File.swift
//  AppUI
//
//  Created by Avery on 2025/10/17.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
public final class DrawerModalPresentation: NSObject, ObservableObject {
    public var duration: TimeInterval
    
    public var drawerPercent: CGFloat
    
    public var presentGesturePercent: CGFloat
    
    public var maskColor: UIColor
    
    public init(
        duration: TimeInterval = 0.25,
        drawerPercent: CGFloat = 0.75,
        presentGesturePercent: CGFloat = 0.25,
        maskColor: UIColor = .black.withAlphaComponent(0.35)
    ) {
        self.duration = duration
        self.drawerPercent = drawerPercent
        self.presentGesturePercent = presentGesturePercent
        self.maskColor = maskColor
    }
    
    public var tippingOffset: CGFloat = 100
    
    private lazy var maskView: MaskView = {
        let view = MaskView()
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(handleTapMaskAction(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private weak var presentingVC: UIViewController?
    
    private weak var presentedVC: UIViewController?
    
    private lazy var dismissGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismiss(pan:)))
    
    private lazy var dismissInteraction: UIPercentDrivenInteractiveTransition = {
        let temp = UIPercentDrivenInteractiveTransition()
        temp.wantsInteractiveStart = false
        return temp
    }()
    
    private var dismissBeganX: CGFloat = 0
    
    private(set) lazy var presentGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePresent(pan:)))
    
    private lazy var presentInteraction: UIPercentDrivenInteractiveTransition = {
        let temp = UIPercentDrivenInteractiveTransition()
        temp.wantsInteractiveStart = false
        return temp
    }()
    
    public var presentAction: (() -> Void)?
    
    private var presentBeganX: CGFloat = 0
}

extension DrawerModalPresentation {
    final class MaskView: UIView {}
    
    @objc
    private func handleTapMaskAction(_ tap: UITapGestureRecognizer) {
        presentedVC?.dismiss(animated: true)
    }
    
    private func screenSize(from view: UIView) -> CGSize {
        guard let window = view.window else {
            assertionFailure("From view's window is nil!")
            return UIScreen.main.bounds.size
        }
        return window.screen.bounds.size
    }
}

extension DrawerModalPresentation: UIViewControllerTransitioningDelegate {
    public func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        self
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        self
    }
    
    public func interactionControllerForDismissal(using animator: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)? {
        dismissInteraction
    }
    
    public func interactionControllerForPresentation(using animator: any UIViewControllerAnimatedTransitioning) -> (any UIViewControllerInteractiveTransitioning)? {
        presentAction == nil ? nil : presentInteraction
    }
}

extension DrawerModalPresentation: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        duration
    }
    
    public func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey:.to)
        else{
            return
        }
        if toVC.isBeingPresented {
            presentingAnimation(fromVC: fromVC, toVC: toVC, context: transitionContext)
        } else if fromVC.isBeingDismissed {
            dismissingAnimation(fromVC: fromVC, toVC: toVC, context: transitionContext)
        }
    }
}

// MARK: - Present
extension DrawerModalPresentation {
    @objc
    private func handlePresent(pan: UIScreenEdgePanGestureRecognizer) {
        guard let presentAction = presentAction else {
            assertionFailure("Present action can not be nil.")
            return
        }
        let window = UIWindow.firstWindow
        let offset = pan.location(in: window).x - presentBeganX
        switch pan.state {
        case .began:
            presentBeganX = pan.location(in: window).x
        case .changed:
            let screenSize = window.screen.bounds.size
            let drawerWidth = screenSize.width * drawerPercent
            guard offset >= 0 else {
                return
            }
            if !presentInteraction.wantsInteractiveStart {
                presentInteraction.wantsInteractiveStart = true
                presentAction()
            }
            
            if drawerWidth != 0 {
                let percent = offset/drawerWidth
                presentInteraction.update(min(percent, 1))
            }
        case .cancelled, .ended:
            if offset >= tippingOffset {
                presentInteraction.finish()
            } else {
                presentInteraction.cancel()
            }
            presentInteraction.wantsInteractiveStart = false
        default:
            presentInteraction.finish()
            presentInteraction.wantsInteractiveStart = false
        }
    }
    
    static var temp: UIView?
    
    private func presentingAnimation(
        fromVC: UIViewController,
        toVC: UIViewController,
        context: any UIViewControllerContextTransitioning
    ) {
        let containerView = context.containerView
        presentingVC = fromVC
        presentedVC = toVC
                
        let fromView: UIView = fromVC.view
        let toView: UIView = toVC.view
        let duration = transitionDuration(using: context)
        
        let screenSize = screenSize(from: fromView)
        
        let drawerWidth = screenSize.width * drawerPercent
        
        let  drawerStartFrame = CGRect(x: -drawerWidth, y: 0, width: drawerWidth, height: screenSize.height)
        toView.frame = drawerStartFrame
        containerView.addSubview(toView)
        
        maskView.backgroundColor = maskColor
        maskView.frame = fromView.frame
        maskView.alpha = 0
        containerView.addSubview(maskView)
        
        UIView.animate(withDuration: duration) {
            self.maskView.alpha = 1.0
            self.maskView.frame.origin.x = drawerWidth
            fromView.frame.origin.x = drawerWidth
            toView.frame.origin.x = 0
            
        } completion: { finished in
            if context.transitionWasCancelled {
                toView.removeFromSuperview()
                self.maskView.removeFromSuperview()
                context.completeTransition(false)
            } else {
                context.completeTransition(true)
                containerView.addGestureRecognizer(self.dismissGesture)
            }
        }
    }
}
// MARK: - Dismiss
extension DrawerModalPresentation {
    @objc
    private func handleDismiss(pan: UIScreenEdgePanGestureRecognizer) {
        guard let presentedVC = presentedVC,
              let window = presentedVC.view.window else {
            return
        }
        let offset = dismissBeganX - pan.location(in: window).x
        switch pan.state {
        case .began:
            dismissBeganX = pan.location(in: window).x
        case .changed:
            let screenSize = window.screen.bounds.size
            let drawerWidth = screenSize.width * drawerPercent
            guard offset >= 0 else { return }
            
            if !dismissInteraction.wantsInteractiveStart {
                dismissInteraction.wantsInteractiveStart = true
                presentedVC.view.endEditing(true)
                presentedVC.dismiss(animated: true)
            }
            
            if offset >= 0, drawerWidth != 0 {
                let percent = offset/drawerWidth
                dismissInteraction.update(min(percent, 1))
            }
        case .cancelled, .ended:
            if offset >= tippingOffset {
                dismissInteraction.finish()
            } else {
                dismissInteraction.cancel()
            }
            dismissInteraction.wantsInteractiveStart = false
        default:
            dismissInteraction.finish()
            dismissInteraction.wantsInteractiveStart = false
        }
    }
    
    private func dismissingAnimation(
        fromVC: UIViewController,
        toVC: UIViewController,
        context: any UIViewControllerContextTransitioning
    ) {
        let containerView = context.containerView
        let fromView: UIView = fromVC.view
        let toView: UIView = toVC.view
        let duration = transitionDuration(using: context)
        
        let screenSize = screenSize(from: fromView)
        let drawerWidth = screenSize.width * drawerPercent
        
        maskView.backgroundColor = maskColor
        maskView.frame = toView.frame
        maskView.alpha = 1
        UIView.animate(withDuration: duration) {
            self.maskView.alpha = 0
            self.maskView.frame.origin.x = 0
            toView.frame.origin.x = 0
            fromView.frame.origin.x = -drawerWidth
        } completion: { finished in
            if context.transitionWasCancelled {
                context.completeTransition(false)
            } else {
                context.completeTransition(true)
                containerView.subviews.forEach {
                    $0.removeFromSuperview()
                }
            }
        }
    }
}
