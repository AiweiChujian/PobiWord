//
//  File.swift
//  BaseKit
//
//  Created by Avery on 2025/4/26.
//

import Foundation

// MARK: - Json codable
public extension Encodable {
    var jsonString: String {
        get throws {
            let data = try JSONEncoder().encode(self)
            guard let string = String(data: data, encoding: .utf8) else {
                throw ExplicitError("无法将JSON数据转换为字符串")
            }
            return string
        }
    }
    
    var jsonValue: String? {
        do {
            return try jsonString
        } catch {
            return nil
        }
    }
}

public extension Optional where Wrapped: Encodable {
    var jsonString: String? {
        get throws {
            guard let value = self else {
                return nil
            }
            return try value.jsonString
        }
    }
    
    var jsonValue: String? {
        guard let value = self else {
            return nil
        }
        return value.jsonValue
    }
}

public extension Decodable {
    init(jsonString: String) throws {
        guard let data = jsonString.data(using: .utf8) else {
            throw ExplicitError("无法将JSON字符串转换为Data类型")
        }
        self = try JSONDecoder().decode(Self.self, from: data)
    }
    
    init?(jsonValue: String?) {
        guard let jsonSting = jsonValue else { return nil }
        do {
            self = try .init(jsonString: jsonSting)
        } catch {
            return nil
        }
    }
}
