//
//  File.swift
//  AppNetwork
//
//  Created by Avery on 2025/7/29.
//

import Foundation
import Alamofire

public extension NetworkApiType {
    /// 完整的URL转换
    func urlConvertible() -> URLConvertible {
        apiBaseURL().appendingPathComponent(apiPath())
    }
    
    /// 默认使用环境配置的基础URL
    func apiBaseURL() -> URL {
        ApiEnvironment.baseURL
    }
    
    /// 是否是上传
    func isUploadTask() -> Bool { false }
    
    /// 默认不需要签名
    func needSignature() -> Bool { false }
    
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
