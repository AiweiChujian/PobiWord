//
//  File.swift
//  AppNetwork
//
//  Created by Avery on 2025/7/29.
//

import Foundation
import Alamofire
import AppLog

import Network
/// 网络错误类型枚举
public enum NetworkError: Error {
    /// 需要验证的网络接口, 缺少验证信息(登录 Token)
    case noAuthorizationHeader
    /// 服务器返回了非 0 的 Code
    case badResponseCode(_ code: Int, msg: String)
    /// 需要的 Data 为空
    case noResponseData(_ code: Int, msg: String)
    /// 数据未找到
    case dataNotFound
    /// Alamofire 抛错
    case afError(_ error: AFError)
    /// 获取 user token 时出错
    case fetchTokenError(_ error: Error)
    /// 网络连接错误
    case connectionError
    /// 请求超时
    case timeoutError
    /// 其它错误
    case otherError(_ error: Error)
    /// Task 的任务被取消
    case taskCancellation
}

// MARK: - 本地化错误描述
extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .taskCancellation:
            return "Task 的任务被取消"
        case .noAuthorizationHeader:
            return "接口需要先登录，但 userToken 为空"
        case .badResponseCode(_, let msg):
            return msg
        case .noResponseData(_, let msg):
            return msg
        case .dataNotFound:
            return "未找到请求的数据"
        case .afError(let error):
            return error.localizedDescription
        case .connectionError:
            return "网络连接失败，请检查网络设置"
        case .timeoutError:
            return "请求超时，请稍后重试"
        case .fetchTokenError(let error):
            return error.localizedDescription
        case .otherError(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - 业务错误信息
extension NetworkError {
    /// 接口返回的是网络连接报错
    public var isNetworkError: Bool {
        switch self {
        case .afError(let error):
            // 检查Alamofire错误
            if let urlError = error.underlyingError as? URLError {
                return urlError.isNetworkError
            } else if case .sessionTaskFailed(let error) = error,
                      let urlError = error as? URLError {
                return urlError.isNetworkError
            } else if case .serverTrustEvaluationFailed = error {
                // 服务器证书验证失败也视为网络错误
                return true
            }
            return false
        case .connectionError, .timeoutError:
            return true
        case .otherError(let error):
            // 检查其他错误中是否包含网络错误
            if let urlError = error as? URLError {
                return urlError.isNetworkError
            }
            return false
        case .badResponseCode, .noResponseData, .noAuthorizationHeader,
             .dataNotFound, .taskCancellation, .fetchTokenError:
            return false
        }
    }
    
    /// 接口中返回的错误信息
    public var businessMsg: String? {
        switch self {
        case .noAuthorizationHeader,
                .afError,
                .connectionError,
                .timeoutError,
                .otherError,
                .dataNotFound,
                .taskCancellation,
                .fetchTokenError:
            return nil
        case .badResponseCode(_, let msg),
                .noResponseData(_, let msg):
            return msg
        }
    }
    
    /// 接口中返回的错误码
    public var businessCode: Int? {
        switch self {
        case .noAuthorizationHeader,
                .afError,
                .connectionError,
                .timeoutError,
                .otherError,
                .dataNotFound,
                .taskCancellation,
                .fetchTokenError:
            return nil
        case .badResponseCode(let code, _),
                .noResponseData(let code, _):
            return code
        }
    }
    
    /// 记录错误到日志
    public func logError() {
        switch self {
        case .taskCancellation:
            log.error(.network, errorDescription ?? "")
        case .noAuthorizationHeader:
            log.error(.network, "授权错误：接口需要先登录但userToken为空")
        case .badResponseCode(let code, let msg):
            log.error(.network, "业务错误码：\(code) 错误信息：\(msg)")
        case .noResponseData(let code, let msg):
            log.error(.network, "无数据错误码：\(code) 错误信息：\(msg)")
        case .dataNotFound:
            log.error(.network, "数据未找到错误：未找到请求的数据")
        case .fetchTokenError(let error):
            log.error(.network, "获取 UserToken 异常：\(error.localizedDescription)")
        case .afError(let error):
            log.error(.network, "Alamofire错误：\(error.localizedDescription)")
        case .connectionError:
            log.error(.network, "网络连接错误：无法连接到网络")
        case .timeoutError:
            log.error(.network, "网络超时错误：请求超时")
        case .otherError(let error):
            log.error(.network, "其他错误：\(error.localizedDescription)")
        }
    }
}

// MARK: - 错误转换
extension NetworkError {
    /// 将一般错误转换为NetworkError
    public static func compactMap(_ error: Error) -> NetworkError {
        if let error = error as? NetworkError {
            return error
        }
        if let error = error as? AFError {
            return .afError(error)
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                log.error(.network, "网络连接错误：\(urlError.localizedDescription)")
                return .connectionError
            case .timedOut:
                log.error(.network, "请求超时：\(urlError.localizedDescription)")
                return .timeoutError
            default:
                break
            }
        }
        log.error(.network, "未知错误类型：\(error.localizedDescription)")
        return .otherError(error)
    }
}

// MARK: - URLError 扩展
extension URLError {
    /// 判断URLError是否为网络错误
    var isNetworkError: Bool {
        switch code {
        case .notConnectedToInternet, .networkConnectionLost,
             .timedOut, .cannotFindHost, .cannotConnectToHost,
             .dnsLookupFailed, .resourceUnavailable, .dataNotAllowed,
             .secureConnectionFailed, .serverCertificateHasBadDate,
             .serverCertificateUntrusted, .serverCertificateHasUnknownRoot,
             .serverCertificateNotYetValid, .clientCertificateRejected:
            return true
        default:
            return false
        }
    }
}
