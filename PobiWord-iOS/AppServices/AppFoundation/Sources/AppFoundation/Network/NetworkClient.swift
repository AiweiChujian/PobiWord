//
//  AppNetwork
//
//  Created by Avery on 2025/7/29.
//

import Foundation
import Alamofire
import Logging

public enum NetworkClient {
    public static var userToken: String?
}

extension NetworkClient {
    static func requestHeaders<T: NetworkRequest>(for api: T, with userToken: String?) async throws(NetworkError) -> HTTPHeaders {
        var headers: HTTPHeaders = api.extraHeaders() ?? HTTPHeaders.default
        if let userToken, !userToken.isEmpty {
            headers.add(name: "Authorization", value: userToken)
        }
        
        return headers
    }
}

// MARK: - 网络请求
extension NetworkClient {
    /// 创建数据请求
    /// - Parameter target: 网络请求目标
    /// - Returns: Alamofire数据请求对象
    static func dataRequest<T: NetworkRequest>(for api: T) async throws(NetworkError) -> DataRequest? {
        let userToken = userToken
        if api.needAuthorization(), userToken?.isEmpty != false {
            return nil
        }
        let headers = try await requestHeaders(for: api, with: userToken)
        let httpMethod = api.httpMethod()
        let defaultEncoder: ParameterEncoder = (httpMethod == .post) ?
        JSONParameterEncoder.default : URLEncodedFormParameterEncoder.default
        
        let session = api.configuredSession()
        return session.request(
            api.urlConvertible(),
            method: httpMethod,
            parameters: api.params,
            encoder: api.parameterEncoder() ?? defaultEncoder,
            headers: headers,
            requestModifier: api.requestModifier()
        ).validate { request, response, data in
            if data != nil {
                return .success(())
            }
            if response.statusCode >= 200 && response.statusCode < 400 {
                return .success(())
            } else {
                logger.error("请求验证失败: \(response.statusCode)")
                return .failure(AFError.responseValidationFailed(reason: .dataFileNil))
            }
        }
    }
}

// MARK: - 网络请求
extension NetworkClient {
    /// 创建数据请求
    /// - Parameter target: 网络请求目标
    /// - Returns: Alamofire数据请求对象
    static func dataUpload<T: NetworkRequest>(for api: T) async throws(NetworkError) -> UploadRequest? {
        let userToken = userToken
        if api.needAuthorization(), userToken?.isEmpty != false {
            return nil
        }
        let headers = try await requestHeaders(for: api, with: userToken)
        
        let httpMethod = api.httpMethod()
        
        let timeoutAdapter = NetworkTimeout(timeoutInterval: 60 * 5)
        
        let interceptor = Interceptor(adapters: [timeoutAdapter])
        let session = api.configuredSession()
        
        return session.upload(
            multipartFormData: { formData in
                api.formData(multipartFormData: formData)
            },
            to: api.urlConvertible(),
            method: httpMethod,
            headers: headers,
            interceptor: interceptor
        ).validate { request, response, data in
            if data != nil {
                return .success(())
            }
            if response.statusCode >= 200 && response.statusCode < 400 {
                return .success(())
            } else {
                logger.error("请求验证失败: \(response.statusCode)")
                return .failure(AFError.responseValidationFailed(reason: .dataFileNil))
            }
        }
    }
}
