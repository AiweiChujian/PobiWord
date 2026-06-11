//
//  File.swift
//  BaseKit
//
//  Created by Avery on 2025/4/26.
//

import Foundation

// MARK: - HasValue
public extension Numeric {
    var hasValue: Bool {
        self != 0
    }
}

public extension Collection {
    var hasValue: Bool {
        !isEmpty
    }
}

public extension Optional where Wrapped: Numeric {
    var hasValue: Bool {
        guard let value = self else {
            return false
        }
        return value != 0
    }
}

public extension Optional where Wrapped: Collection {
    var hasValue: Bool {
        guard let value = self else {
            return false
        }
        return !value.isEmpty
    }
}

public extension Optional where Wrapped == Bool {
    var isTrue: Bool {
        guard let value = self else {
            return false
        }
        return value
    }
    
    var notTrue: Bool {
        !isTrue
    }
    
    var isFalse: Bool {
        guard let value = self else {
            return false
        }
        return value == false
    }
    
    var notFalse: Bool {
        !isFalse
    }
}
