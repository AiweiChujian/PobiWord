//
//  File.swift
//  STNetwork
//
//  Created by Avery on 2025/4/28.
//

import Foundation
import AppLog

public struct UserCredential: Codable {
    public var id: Int
    public var create_time: String?
    public var device_id: String?
    public var register_app_name: String?
    public var register_app_version: String?
    public var register_ip: String?
    public var register_region: String?
    public var register_type: String?
    public var update_time: String?
    
    public var token: UserToken
    
    public struct UserToken: Codable {
        public var expire_at: Double?
        public var refresh_expire_at: Double?
        public var refresh_token: String?
        public var token: String
    }
}

enum UserTokenManager {
    private static let credentialKey: String = {
        let bundleId = Bundle.main.bundleIdentifier ?? "com.styleTransfer.ai"
        return "\(bundleId).userCredential"
    }()
    
    static private var _userCredential: UserCredential?
    
    private static var userCredential: UserCredential {
        get async throws(NetworkError) {
            if let _userCredential {
                return _userCredential
            }
            if let data = UserDefaults.standard.data(forKey: credentialKey),
               let credential = try? JSONDecoder().decode(UserCredential.self, from: data) {
                _userCredential = credential
                return credential
            }
            let result = try await fetchCredential()
            saveUserCredential(result)
            _userCredential = result
            return result
        }
    }
    
    static var userToken: String {
        get async throws(NetworkError) {
            try await userCredential.token.token
        }
    }
}

extension UserTokenManager {
    /// 保存 UserCredential 到 UserDefaults
    static func saveUserCredential(_ credential: UserCredential) {
        do {
            let data = try JSONEncoder().encode(credential)
            UserDefaults.standard.set(data, forKey: credentialKey)
        } catch {
            log.error(.network, "Encode UserCredential error:", error)
        }
    }
    
    /// 清除 UserCredential（可选）
    static func clearUserCredential() {
        UserDefaults.standard.removeObject(forKey: credentialKey)
    }
}

extension UserTokenManager {
    actor TaskCreator {
        private var loginTask: Task<UserCredential, Error>?
        
        func makeLoginTask() -> Task<UserCredential, Error> {
            if let loginTask {
                return loginTask
            }
            let task = Task<UserCredential, Error> {
                try await AnonymousLoginRequest()
                    .resumeTask()
            }
            loginTask = task
            return task
        }
        
        func resetTask() {
            loginTask = nil
        }
    }
    
    private static var taskCreator = TaskCreator()
    
    /// 异步网络请求获取 token 的方法
    @MainActor
    private static func fetchCredential() async throws(NetworkError) -> UserCredential {
        func networkError(for loginError: Error) -> NetworkError {
            if let error = loginError as? NetworkError {
                return error
            }
            return .fetchTokenError(loginError)
        }
        
        let loginTask = await taskCreator.makeLoginTask()
        do {
            return try await loginTask.value
        } catch {
            await taskCreator.resetTask()
            throw networkError(for: error)
        }
    }
}
