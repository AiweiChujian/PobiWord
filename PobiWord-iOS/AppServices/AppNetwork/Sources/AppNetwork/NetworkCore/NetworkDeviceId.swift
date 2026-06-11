//
//  File.swift
//  STNetwork
//
//  Created by Avery on 2025/4/28.
//

import Foundation
import Security

public enum NetworkDeviceId {
    private static let service = Bundle.main.bundleIdentifier ?? "com.styleTransfer.ai"
    private static let account = "network_deviceId"
    
    private static var _deviceId: String?

    /// 获取或创建唯一设备ID
    public static func deviceId() -> String {
        if let _deviceId {
            return _deviceId
        }
        if let existingId = readUUID() {
            _deviceId = existingId
            return existingId
        }
        let newDeviceId = UUID().uuidString
        _deviceId = newDeviceId
        saveUUID(uuid: newDeviceId)
        return newDeviceId
    }
    
    /// 删除用户信息
    public static func resetDeviceId() {
        if readUUID() != nil && ApiEnvironment.isDevelopment {
            let newDeviceId = UUID().uuidString
            _deviceId = newDeviceId
            saveUUID(uuid: newDeviceId)
            UserTokenManager.clearUserCredential()
        }
    }

    /// 读取 Keychain 中的 UUID
    private static func readUUID() -> String? {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : account,
            kSecReturnData as String  : true,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let uuid = String(data: data, encoding: .utf8) else {
            return nil
        }
        return uuid
    }

    /// 保存 UUID 到 Keychain
    private static func saveUUID(uuid: String) {
        if let data = uuid.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String       : kSecClassGenericPassword,
                kSecAttrService as String : service,
                kSecAttrAccount as String : account
            ]

            // 先尝试更新已有的 item
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: data
            ]
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

            if status == errSecItemNotFound {
                // 不存在则添加新条目
                var newItem = query
                newItem[kSecValueData as String] = data
                SecItemAdd(newItem as CFDictionary, nil)
            }
        }
    }
}
