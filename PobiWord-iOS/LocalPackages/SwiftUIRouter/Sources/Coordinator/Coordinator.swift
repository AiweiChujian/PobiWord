//
//  File.swift
//  MVVMRedux
//
//  Created by Avery on 2026/4/2.
//

import Foundation
@_exported import UIRouter


@MainActor
public protocol FeatureCoordinator: AnyObject {
    associatedtype Global: GlobalRouter
    associatedtype Local: ExportableRouter

    static func registerRoutes(in global: Global)

    var global: Global { get }
    var router: Local { get }
}
