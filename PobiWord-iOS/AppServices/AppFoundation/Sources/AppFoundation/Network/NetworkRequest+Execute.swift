//
//  File.swift
//  AppNetwork
//
//  Created by Avery on 2025/7/29.
//

import Foundation
import Alamofire

public extension NetworkRequest {
    /// 执行请求并返回响应数据
    /// - Returns: 解码后的响应数据
    @MainActor
    func execute<ResponseData: Codable>() async throws(NetworkError) -> ResponseData? {
        do {
            let task: DataTask<NetworkResponse.Base<ResponseData>>?
            if isUploadTask() {
                task = try await NetworkClient.dataUpload(for: self)?
                    .serializingDecodable(NetworkResponse.Base<ResponseData>.self)
            } else {
                task = try await NetworkClient.dataRequest(for: self)?
                    .serializingDecodable(NetworkResponse.Base<ResponseData>.self)
            }
            guard let task else { return nil }
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
    @MainActor @discardableResult
    func executeWithoutData() async throws(NetworkError) -> Bool {
        let result: NetworkResponse.EmptyData? = try await execute()
        return result != nil
    }
}
