//
//  File.swift
//  AppNetwork
//
//  Created by Avery on 2025/7/29.
//

import Foundation
import Alamofire

public protocol NetworkParameters: Encodable {}


public struct NetworkEmptyParams: NetworkParameters {}

/// 网络请求协议
public protocol NetworkRequest {
    associatedtype Params: Encodable
    
    typealias EmptyParams = NetworkEmptyParams
    /// 参数
    var params: Params? { get }
    
    /// HTTP请求方法
    func httpMethod() -> HTTPMethod
    
    /// API基础URL
    func apiBaseURL() -> URL
    
    /// API路径
    func apiPath() -> String
    
    /// 是否需要授权
    func needAuthorization() -> Bool
    
    /// 是否是上传
    func isUploadTask() -> Bool
    
    ///  已配置好的网络 session
    func configuredSession() -> Session
    
    /// 额外的 headers
    func extraHeaders() -> HTTPHeaders?
    
    /// 参数编码器
    func parameterEncoder() -> ParameterEncoder?
    
    /// 请求修改器
    func requestModifier() -> Session.RequestModifier?
    
    /// 如果上传文件，需要调用者自己组装FormData
    func formData(multipartFormData: MultipartFormData)
}

public extension NetworkRequest where Params == EmptyParams {
    var params: Params? { nil }
}

public extension NetworkRequest {
    /// 完整的URL转换
    func urlConvertible() -> URLConvertible {
        apiBaseURL().appendingPathComponent(apiPath())
    }
    
    /// 默认使用环境配置的基础URL
    func apiBaseURL() -> URL {
        ServerHost.baseURL
    }
    
    /// 是否是上传
    func isUploadTask() -> Bool { false }
    
    ///  已配置好的网络 session
    func configuredSession() -> Session {
        let session = Session.default
        session.sessionConfiguration.allowsExpensiveNetworkAccess = true
        session.sessionConfiguration.allowsConstrainedNetworkAccess = true
        session.sessionConfiguration.httpMaximumConnectionsPerHost = 10
        session.sessionConfiguration.timeoutIntervalForRequest = 30
        return session
    }
    
    /// 默认无额外请求头
    func extraHeaders() -> HTTPHeaders? { nil }
    
    /// 默认无参数编码器
    func parameterEncoder() -> ParameterEncoder? { nil }
    
    /// 默认无请求修改器
    func requestModifier() -> Session.RequestModifier? { nil }
    
    // 默认无需修改
    func formData(multipartFormData: MultipartFormData) { }
}
