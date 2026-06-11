//
//  File.swift
//  AppNetwork
//
//  Created by Avery on 2025/7/29.
//

import Foundation
import Alamofire

public protocol NetworkApiParameters: Encodable {}

// 约定公共参数
public protocol NetworkCheckedParams: NetworkApiParameters {
    
}

public struct NetworkEmptyParams: NetworkApiParameters {
    
}

/// 网络请求协议
public protocol NetworkApiType {
    associatedtype Parameters: Encodable
    
    typealias EmptyParameters = NetworkEmptyParams
    /// 参数
    var paramsters: Parameters? { get }
    
    /// HTTP请求方法
    func httpMethod() -> HTTPMethod
    
    /// API基础URL
    func apiBaseURL() -> URL
    
    /// API路径
    func apiPath() -> String
    
    /// 是否需要授权
    func needAuthorization() -> Bool
    
    /// 是否需要签名
    func needSignature() -> Bool
    
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

public extension NetworkApiType where Parameters == EmptyParameters {
    var paramsters: Parameters? { nil }
}

// MARK: 发起网络请求
public extension NetworkApiType {
    /// 执行请求并返回响应数据
    /// - Returns: 解码后的响应数据
    func resumeTask<ResponseData: Codable>() async throws(NetworkError) -> ResponseData {
        do {
            let task: DataTask<NetworkResponse.Base<ResponseData>>
            if isUploadTask() {
                task = try await NetworkContext.dataUpload(for: self)
                    .serializingDecodable(NetworkResponse.Base<ResponseData>.self)
            } else {
                task = try await NetworkContext.dataRequest(for: self)
                    .serializingDecodable(NetworkResponse.Base<ResponseData>.self)
            }
            let response = await task.response
#if DEBUG
            if let data = response.data {
                debugPrint("response.data: \(String(data: data, encoding: .utf8) ?? "")")
            }
#endif
            switch response.result {
            case .success(let base):
                do {
                    return try base.responseData
                } catch let networkError {
                    // 处理业务错误
                    throw networkError
                }
            case .failure(let error):
                throw NetworkError.afError(error)
            }
        } catch {
            throw NetworkError.compactMap(error)
        }
    }
    
    /// 执行请求不关心响应数据
    func resumeTaskWithoutData() async throws(NetworkError) {
        let _: NetworkResponse.EmptyData = try await resumeTask()
    }
}
