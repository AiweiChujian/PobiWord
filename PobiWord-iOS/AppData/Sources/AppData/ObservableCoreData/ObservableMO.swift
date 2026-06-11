//
//  ObservableMO.swift
//  MVVMReduxDemo
//
//  Created by Avery on 2024/9/13.
//

import Foundation
import SwiftUI

public final class ObservableMO<T: ObservableManagedObject>: ObservableObject, ObservableContainer {
    public let managedObj: T
    public init(_ managedObj: T) {
        self.managedObj = managedObj
    }
}

