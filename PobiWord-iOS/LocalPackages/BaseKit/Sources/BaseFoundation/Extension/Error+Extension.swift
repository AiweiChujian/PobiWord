//
//  File.swift
//  BaseKit
//
//  Created by Avery on 2025/4/26.
//

import Foundation

public struct ExplicitError: Error {
    public var msg: String
    
    public var rawError: Error?
    
    public init(_ msg: String, rawError: Error? = nil) {
        self.msg = msg
        self.rawError = rawError
    }
}
