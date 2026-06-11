//
//  File.swift
//  SwiftUIRouter
//
//  Created by Avery on 2026/4/3.
//

import Foundation
import SwiftUI
import UIRouter
import Router


// MARK: - ExportableRoutePath
public protocol ExportableRoutePath {
    func buildView<T>(with router: any UIRouter, input: T) -> AnyView?
}

extension RoutePath: ExportableRoutePath {
    public func buildView<T>(with router: any UIRouter, input: T) -> AnyView? {
        guard let router = router as? R, let input = input as? Input else {
            return nil
        }
        return using(router: router, input: input)
    }
}

// MARK: - ExportableRouter
public protocol ExportableRouter: UIRouter {
    associatedtype RouteKey: Hashable

    var exportedPaths: [RouteKey: ExportableRoutePath] { get }
}
