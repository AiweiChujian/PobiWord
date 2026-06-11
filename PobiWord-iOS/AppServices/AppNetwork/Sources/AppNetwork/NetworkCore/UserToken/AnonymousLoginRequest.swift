//
//  File.swift
//  STNetwork
//
//  Created by Avery on 2025/4/28.
//

import Foundation
import Alamofire

/// 模板获取请求
public struct AnonymousLoginRequest: NetworkApiType {
    public struct Parameters: NetworkCheckedParams {

    }
    
    public var paramsters: Parameters? {
        assertionFailure("设置公共参数")
        return .init()
    }
    
    /// HTTP请求方法
    public func httpMethod() -> HTTPMethod { .post }
    
    /// API路径
    public func apiPath() -> String {
        assertionFailure("api path")
        return "/v1/user/login/device_id"
    }
    
    /// 是否需要授权
    public func needAuthorization() -> Bool {
        false
    }
    
    /// 是否需要签名
    public func needSignature() -> Bool {
        true
    }
}

