import Foundation
import CommonCrypto

/// AES 加密/解密工具，兼容 OpenSSL 命令行
class AESCryptoHelper {
    // MARK: - 加密方法

    /// 使用 AES-ECB 加密文本并返回 Base64 编码的字符串
    static func encryptWithAesEcb(plainText: String, hexKey: String) throws -> String {
        guard let data = plainText.data(using: .utf8) else {
            throw NSError(domain: "AESCryptoHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法将文本转换为 UTF-8 数据"])
        }
        let encryptedData = try encryptWithAesEcb(data: data, hexKey: hexKey)
        return encryptedData.base64EncodedString()
    }

    /// 使用 AES-ECB 加密数据并返回加密数据
    static func encryptWithAesEcb(data: Data, hexKey: String) throws -> Data {
        guard let keyData = hexStringToData(hexKey) else {
            throw NSError(domain: "AESCryptoHelper", code: -2, userInfo: [NSLocalizedDescriptionKey: "无效的十六进制密钥"])
        }
        let validKeyLengths = [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256]
        guard validKeyLengths.contains(keyData.count) else {
            throw NSError(domain: "AESCryptoHelper", code: -3, userInfo: [NSLocalizedDescriptionKey: "密钥长度无效，必须为 16、24 或 32 字节 (当前: \(keyData.count))"])
        }
        let bufferSize = data.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        var numBytesEncrypted = 0
        let cryptStatus = buffer.withUnsafeMutableBytes { bufferPtr in
            data.withUnsafeBytes { dataPtr in
                keyData.withUnsafeBytes { keyPtr in
                    CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionECBMode + kCCOptionPKCS7Padding),
                        keyPtr.baseAddress,
                        keyData.count,
                        nil,   // ECB 不需要 IV
                        dataPtr.baseAddress,
                        data.count,
                        bufferPtr.baseAddress,
                        bufferSize,
                        &numBytesEncrypted
                    )
                }
            }
        }
        if cryptStatus != kCCSuccess {
            throw NSError(domain: "AESCryptoHelper", code: -4, userInfo: [NSLocalizedDescriptionKey: "加密操作失败，状态码: \(cryptStatus)"])
        }
        return buffer.prefix(numBytesEncrypted)
    }

    // MARK: - 解密方法

    /// 解密 Base64 编码的 AES-ECB 加密文本，返回解密后的字符串
    static func decryptWithAesEcb(encryptedBase64: String, hexKey: String) throws -> String {
        guard let encryptedData = Data(base64Encoded: encryptedBase64) else {
            throw NSError(domain: "AESCryptoHelper", code: -10, userInfo: [NSLocalizedDescriptionKey: "无效的 Base64 编码"])
        }
        return try decryptWithAesEcb(encryptedData: encryptedData, hexKey: hexKey)
    }

    /// 解密 AES-ECB 加密的数据，返回字符串
    static func decryptWithAesEcb(encryptedData: Data, hexKey: String) throws -> String {
        guard let keyData = hexStringToData(hexKey) else {
            throw NSError(domain: "AESCryptoHelper", code: -11, userInfo: [NSLocalizedDescriptionKey: "无效的十六进制密钥"])
        }
        let validKeyLengths = [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256]
        guard validKeyLengths.contains(keyData.count) else {
            throw NSError(domain: "AESCryptoHelper", code: -12, userInfo: [NSLocalizedDescriptionKey: "密钥长度无效，必须为 16、24 或 32 字节 (当前: \(keyData.count))"])
        }
        let bufferSize = encryptedData.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        var numBytesDecrypted = 0
        let cryptStatus = buffer.withUnsafeMutableBytes { bufferPtr in
            encryptedData.withUnsafeBytes { dataPtr in
                keyData.withUnsafeBytes { keyPtr in
                    CCCrypt(
                        CCOperation(kCCDecrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionECBMode + kCCOptionPKCS7Padding),
                        keyPtr.baseAddress,
                        keyData.count,
                        nil,
                        dataPtr.baseAddress,
                        encryptedData.count,
                        bufferPtr.baseAddress,
                        bufferSize,
                        &numBytesDecrypted
                    )
                }
            }
        }
        if cryptStatus != kCCSuccess {
            throw NSError(domain: "AESCryptoHelper", code: -13, userInfo: [NSLocalizedDescriptionKey: "解密操作失败，状态码: \(cryptStatus)"])
        }
        let decryptedData = buffer.prefix(numBytesDecrypted)
        guard let result = String(data: decryptedData, encoding: .utf8) else {
            throw NSError(domain: "AESCryptoHelper", code: -14, userInfo: [NSLocalizedDescriptionKey: "解密成功但无法解析为 UTF-8 字符串"])
        }
        return result
    }

    // MARK: - 辅助方法

    /// 将十六进制字符串转换为 Data
    static func hexStringToData(_ hexString: String) -> Data? {
        let trimmedString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        var data = Data(capacity: trimmedString.count / 2)
        var i = trimmedString.startIndex
        while i < trimmedString.endIndex {
            let nextIndex = trimmedString.index(i, offsetBy: 2, limitedBy: trimmedString.endIndex) ?? trimmedString.endIndex
            let byteString = trimmedString[i..<nextIndex]
            if let num = UInt8(byteString, radix: 16) {
                data.append(num)
            } else {
                return nil
            }
            i = nextIndex
        }
        return data
    }

    /// Data 转十六进制字符串
    static func dataToHexString(_ data: Data, uppercase: Bool = false) -> String {
        let format = uppercase ? "%02X" : "%02x"
        return data.map { String(format: format, $0) }.joined()
    }
}

// MARK: - 与 OpenSSL 兼容扩展
extension AESCryptoHelper {
    static func opensslEncryptAes128Ecb(plainText: String, hexKey: String) throws -> String {
        return try encryptWithAesEcb(plainText: plainText, hexKey: hexKey)
    }
    static func opensslDecryptAes128Ecb(encryptedBase64: String, hexKey: String) throws -> String {
        return try decryptWithAesEcb(encryptedBase64: encryptedBase64, hexKey: hexKey)
    }
}

// MARK: - 测试
extension AESCryptoHelper {
    /// 测试加密和解密一致性
    static func testEncryptionDecryption(originalText: String, hexKey: String) -> (success: Bool, details: String) {
        do {
            let base64String = try encryptWithAesEcb(plainText: originalText, hexKey: hexKey)
            let decryptedText = try decryptWithAesEcb(encryptedBase64: base64String, hexKey: hexKey)
            let success = (originalText == decryptedText)
            let details = """
            原始文本: "\(originalText)"
            加密结果: \(base64String)
            解密结果: "\(decryptedText)"
            测试结果: \(success ? "通过" : "失败")
            """
            return (success, details)
        } catch {
            return (false, "加解密出错: \(error.localizedDescription)")
        }
    }
    /// 测试 OpenSSL 命令行兼容性
    static func testOpenSSLCompatibility(encryptedBase64: String, expectedText: String, hexKey: String) -> (success: Bool, details: String) {
        do {
            let decryptedText = try decryptWithAesEcb(encryptedBase64: encryptedBase64, hexKey: hexKey)
            let success = (expectedText == decryptedText)
            let details = """
            OpenSSL 加密: \(encryptedBase64)
            预期明文: "\(expectedText)"
            解密结果: "\(decryptedText)"
            测试结果: \(success ? "通过" : "失败")
            """
            return (success, details)
        } catch {
            return (false, "解密失败: \(error.localizedDescription)")
        }
    }
}

