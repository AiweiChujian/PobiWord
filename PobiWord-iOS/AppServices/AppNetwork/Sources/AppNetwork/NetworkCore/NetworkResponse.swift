//
//  File.swift
//  AppNetwork
//
//  Created by Avery on 2025/7/29.
//

import Foundation

public enum NetworkResponse {
    /// 标准API响应基础结构
    public struct Base<T: Codable>: Codable {
        /// 接口返回状态码，0表示成功
        public let code: Int
        /// 接口返回数据
        public let data: T?
        /// 接口返回消息
        public let msg: String
        
        /// 获取响应数据，如果失败则抛出错误
        public var responseData: T {
            get throws(NetworkError) {
                guard let data = try optionalResponseData else {
                    throw NetworkError.noResponseData(code, msg: msg)
                }
                return data
            }
        }
        
        /// 获取可选响应数据，如果状态码不为0则抛出错误
        public var optionalResponseData: T? {
            get throws(NetworkError) {
                guard code == 0 else {
                    throw NetworkError.badResponseCode(code, msg: msg)
                }
                return data
            }
        }
    }
}

public extension NetworkResponse {
    /// 表示空数据响应的结构体
    struct EmptyData: Codable {}
}

