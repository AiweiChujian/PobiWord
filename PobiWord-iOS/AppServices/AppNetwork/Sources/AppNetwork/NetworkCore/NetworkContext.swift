//
//  File.swift
//  AppNetwork
//
//  Created by Avery on 2025/7/29.
//

import Foundation
import Alamofire
import AppLog

enum NetworkContext {
    static var appVersion: String {
        guard let infoDictionary = Bundle.main.infoDictionary else { return "1.0.0" }
        let majorVersion = infoDictionary["CFBundleShortVersionString"] as? String
        return majorVersion ?? "1.0.0"
    }
    
    static var appName: String {
        assertionFailure("设置 App Name")
        return "AppDemo"
    }
    
    static let signatureKey = SignatureKeyManager.getSignatureKey()
}

extension NetworkContext {
    static func requestHeaders<T: NetworkApiType>(for api: T) async throws(NetworkError) -> HTTPHeaders? {
        var headers: HTTPHeaders = api.extraHeaders() ?? HTTPHeaders.default
        if api.needAuthorization() {
            //            let userToken = try await UserTokenManager.userToken
            //            if userToken.isEmpty {
            //                log.error(.network, "授权Token为空")
            //                throw NetworkError.noAuthorizationHeader
            //            }
            //            headers.add(name: "Authorization", value: userToken)
        }
        
        if api.needSignature() {
            let secretKey = signatureKey
            if secretKey.isEmpty {
                let message = "签名失败: signatureKey: nil"
                log.error(.network, message)
                throw NetworkError.otherError(NSError(domain: message, code: -1))
            }
            
            let signature: String
            do {
                signature = try AESCryptoHelper.encryptWithAesEcb(plainText: NetworkDeviceId.deviceId(), hexKey: secretKey)
            } catch {
                throw NetworkError.otherError(error)
            }
            headers.add(name: "X-Device-ID", value: signature)
        }
        return headers
    }
}

// MARK: - 网络请求
extension NetworkContext {
    /// 创建数据请求
    /// - Parameter target: 网络请求目标
    /// - Returns: Alamofire数据请求对象
    static func dataRequest<T: NetworkApiType>(for api: T) async throws(NetworkError) -> DataRequest {
        let headers = try await requestHeaders(for: api)
        let httpMethod = api.httpMethod()
        let defaultEncoder: ParameterEncoder = (httpMethod == .post) ?
        JSONParameterEncoder.default : URLEncodedFormParameterEncoder.default
        
        let session = api.configuredSession()
        return session.request(
            api.urlConvertible(),
            method: httpMethod,
            parameters: api.paramsters,
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
                log.error(.network, "请求验证失败: \(response.statusCode)")
                return .failure(AFError.responseValidationFailed(reason: .dataFileNil))
            }
        }
    }
}

// MARK: - 网络请求
extension NetworkContext {
    /// 创建数据请求
    /// - Parameter target: 网络请求目标
    /// - Returns: Alamofire数据请求对象
    static func dataUpload<T: NetworkApiType>(for api: T) async throws(NetworkError) -> UploadRequest {
        let headers = try await requestHeaders(for: api)
        
        let httpMethod = api.httpMethod()
        
        let timeoutAdapter = TimeoutRequestAdapter(timeoutInterval: 60 * 10)
        
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
                log.error(.network, "请求验证失败: \(response.statusCode)")
                return .failure(AFError.responseValidationFailed(reason: .dataFileNil))
            }
        }
    }
}
