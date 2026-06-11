//
//  File.swift
//  AppUI
//
//  Created by Avery on 2025/9/17.
//

import Foundation
import UIKit
import SwiftUI

public struct ZoomTransitionEntrance<Content: View>: UIViewRepresentable {
    var content: () -> Content
    
    private(set) var transitionActionHandler: ((UIView) -> Void)?
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> ContainerView {
        context.coordinator.containerView
    }
    
    public func updateUIView(_ uiView: ContainerView, context: Context) {
        context.coordinator.entrance = self
        uiView.layoutIfNeeded()
    }
    
    func makeHosting() -> UIHostingController<Content> {
        let hosting = UIHostingController(rootView: content())
        hosting.sizingOptions = [.intrinsicContentSize]
        return hosting
    }
    
    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: ContainerView, context: Context) -> CGSize? {
        let maxSize: CGFloat = 10_000
        let targetSize = CGSize(
            width: proposal.width ?? maxSize,
            height: proposal.height ?? maxSize
        )
        let hosting = context.coordinator.containerView.hosting
        return hosting.sizeThatFits(in: targetSize)
    }
}

extension ZoomTransitionEntrance {
    @MainActor
    public final class Coordinator {
        var entrance: ZoomTransitionEntrance {
            didSet { updateUIView() }
        }
        
        let containerView: ContainerView
        
        init(_ entrance: ZoomTransitionEntrance) {
            self.entrance = entrance
            self.containerView = .init(hosting: entrance.makeHosting())
            updateUIView()
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
            containerView.addGestureRecognizer(tap)
        }
        @objc
        private func tapAction(_ sender: UITapGestureRecognizer) {
            entrance.transitionActionHandler?(containerView)
        }
        
        func updateUIView() {
            containerView.hosting.rootView = entrance.content()
            containerView.updateHostingViewIfNeeded()
        }
    }
}

extension ZoomTransitionEntrance {
    public final class ContainerView: UIButton {
        var hosting: UIHostingController<Content> {
            didSet { updateHostingViewIfNeeded() }
        }
        
        init(hosting: UIHostingController<Content>) {
            self.hosting = hosting
            super.init(frame: .zero)
            backgroundColor = .clear
            updateHostingViewIfNeeded()
        }
        
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        private var last: UIView?
        
        func updateHostingViewIfNeeded() {
            let hostingView = hosting.view
            guard last != hostingView else { return }
            
            if let last {
                last.removeFromSuperview()
            }
            guard let newView = hostingView else {
                return
            }
            last = newView
            addSubview(newView)
            newView.backgroundColor = .clear
            newView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                newView.topAnchor.constraint(equalTo: topAnchor),
                newView.leadingAnchor.constraint(equalTo: leadingAnchor),
                newView.trailingAnchor.constraint(equalTo: trailingAnchor),
                newView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }
}

public extension ZoomTransitionEntrance {
    func transitionAction(_ value: @escaping (_ source: UIView) -> Void) -> Self {
        var new = self
        new.transitionActionHandler = value
        return new
    }
}
