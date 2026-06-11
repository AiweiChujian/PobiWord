//
//  File.swift
//  AppNetwork
//
//  Created by Avery on 2025/7/29.
//


import Foundation

struct SignatureKeyManager {
    // 存储混淆算法需要的关键信息
    private static let shuffleMap: [Int] = {
        switch ApiEnvironment.current {
        case .development:
            return [5, 3, 2, 4, 1, 6, 7, 0]
        case .production:
            return [0, 5, 2, 6, 1, 3, 4, 7]
        }
    }() // 可根据需要调整
    
    // 私有初始化方法，防止外部直接创建实例
    private init() {}
    
    /// 获取最终的签名密钥
    static func getSignatureKey() -> String {
        let obfuscatedChars = getObfuscatedCharacters()
        return deobfuscateKey(obfuscatedChars)
    }
    
    /// 获取混洗的关键字符数组
    static func getObfuscatedCharacters() -> [String] {
        // 这里应该是从createNewObfuscation方法生成的混淆字符数组
        switch ApiEnvironment.current {
        case .development:
            return ["62h:", "82dh", "d;59", "75hh", "bgh6", "52h8", "376:", "eggh"]
        case .production:
            return ["68ei", "3996", ":86g", "g59f", "7g8;", ":276", "e3e8", "c7<<"]
        }
    }
    
    /// 将混淆字符解混淆并重组为最终密钥
    private static func deobfuscateKey(_ obfuscatedParts: [String]) -> String {
        // 创建一个足够大的数组来存储结果
        var resultParts = [String](repeating:"",count:obfuscatedParts.count)
        
        // shuffleMap[i] = j 表示原始密钥的第i部分被放在了混淆数组的第j位
        for (originalIndex, shuffledIndex) in shuffleMap.enumerated() {
            if shuffledIndex < obfuscatedParts.count {
                // 从混淆数组的shuffledIndex位置获取部分，并应用解混淆
                resultParts[originalIndex] = reverseSimpleObfuscation(obfuscatedParts[shuffledIndex])
            }
        }
        
        // 连接所有部分
        return resultParts.joined()
    }
    
    /// 应用简单可靠的混淆
    static func applySimpleObfuscation(_ input: String) -> String {
        var result = ""
        let chars = Array(input)
        
        for (i, char) in chars.enumerated() {
            if let ascii = char.asciiValue {
                // 简单偏移混淆，仅使用可打印ASCII范围(32-126)
                let offset = UInt8(i % 5) + 1 // 1-5的偏移
                var newAscii = ascii + offset
                
                // 确保在可打印ASCII范围内
                if newAscii > 126 {
                    newAscii = 32 + (newAscii - 126)
                }
                
                if let scalar = UnicodeScalar(UInt32(newAscii)) {
                    result.append(Character(scalar))
                }
            } else {
                // 保留非ASCII字符不变
                result.append(char)
            }
        }
        
        return result
    }
    
    /// 反向简单混淆
    static func reverseSimpleObfuscation(_ input: String) -> String {
        var result = ""
        let chars = Array(input)
        
        for (i, char) in chars.enumerated() {
            if let ascii = char.asciiValue {
                // 应用相反的偏移
                let offset = UInt8(i % 5) + 1 // 1-5的偏移
                var newAscii = ascii - offset
                
                // 处理下溢
                if newAscii < 32 {
                    newAscii = 126 - (32 - newAscii)
                }
                
                if let scalar = UnicodeScalar(UInt32(newAscii)) {
                    result.append(Character(scalar))
                }
            } else {
                // 保留非ASCII字符不变
                result.append(char)
            }
        }
        
        return result
    }
#if DEBUG
    /// 创建新的混淆映射 - 修复版本
    static func createNewObfuscation(for originalKey: String) -> (obfuscatedParts: [String], shuffleMap: [Int]) {
        // 将原始密钥分割成4字符一组
        var parts: [String] = []
        for i in stride(from: 0, to: originalKey.count, by: 4) {
            let startIndex = originalKey.index(originalKey.startIndex, offsetBy: i)
            let endIndex = originalKey.index(startIndex, offsetBy: min(4, originalKey.count - i))
            let part = String(originalKey[startIndex..<endIndex])
            parts.append(part)
        }
        
        // 如果最后一部分不足4个字符，填充到4个
        if let lastPart = parts.last, lastPart.count < 4 {
            let paddedPart = lastPart + String(repeating: "*", count: 4 - lastPart.count)
            parts[parts.count - 1] = paddedPart
        }
        
        // 创建一个随机的洗牌索引数组
        let partCount = parts.count
        var indices = Array(0..<partCount)
        indices.shuffle() // 随机打乱顺序
        
        // 创建shuffleMap：原始索引->混淆后索引的映射
        var newShuffleMap = Array(repeating: 0, count: partCount)
        for i in 0..<partCount {
            // 记录原始位置i在混淆后的位置
            newShuffleMap[i] = indices[i]
        }
        
        // 创建混淆后的部分数组
        var obfuscatedParts = Array(repeating: "", count: partCount)
        
        // 混淆每个部分并放入正确的位置
        for (originalIndex, shuffledIndex) in newShuffleMap.enumerated() {
            if originalIndex < parts.count {
                // 对原始部分应用混淆
                obfuscatedParts[shuffledIndex] = applySimpleObfuscation(parts[originalIndex])
            }
        }
        
        return (obfuscatedParts, newShuffleMap)
    }
    
    /// 更新密钥（修复版）- 用于生成新的混淆映射
    static func updateSignatureKey(newKey: String) -> String {
        // 生成新的混淆映射
        let result = createNewObfuscation(for: newKey)
        
        // 格式化输出混淆字符数组
        let obfuscatedArrayString = result.obfuscatedParts
            .map { "\"\($0)\"" }
            .joined(separator: ", ")
        
        // 格式化输出洗牌映射
        let shuffleMapString = result.shuffleMap
            .map { String($0) }
            .joined(separator: ", ")
        
        // 验证是否可以正确恢复
        let recoveredKey = testRecovery(
            originalKey: newKey,
            obfuscatedParts: result.obfuscatedParts,
            shuffleMap: result.shuffleMap
        )
        
        // 构建完整的输出
        var output = """
        // 混淆字符数组:
        static func getObfuscatedCharacters() -> [String] {
            return [
                \(obfuscatedArrayString)
            ]
        }
        
        // 洗牌映射:
        private static let shuffleMap: [Int] = [\(shuffleMapString)]
        
        """
        
        output += "// 恢复的密钥: \(recoveredKey)\n"
        output += "// 原始密钥: \(newKey)\n"
        output += "// 验证: \(recoveredKey == newKey ? "✓ 成功" : "✗ 失败")"
        
        return output
    }
    
    /// 测试是否可以正确恢复密钥
    static func testRecovery(originalKey: String, obfuscatedParts: [String], shuffleMap: [Int]) -> String {
        // 创建一个足够大的数组来存储结果
        var resultParts = [String](repeating:"",count:obfuscatedParts.count)
        
        // shuffleMap[i] = j 表示原始密钥的第i部分被放在了混淆数组的第j位
        for (originalIndex, shuffledIndex) in shuffleMap.enumerated() {
            if shuffledIndex < obfuscatedParts.count {
                // 从混淆数组的shuffledIndex位置获取部分，并应用解混淆
                resultParts[originalIndex] = reverseSimpleObfuscation(obfuscatedParts[shuffledIndex])
            }
        }
        
        // 连接所有部分并截取与原始密钥相同长度
        let recoveredKey = resultParts.joined()
        return String(recoveredKey.prefix(originalKey.count))
    }
#endif
}

// 完整测试流程
//func runFullTest() {
//
//    let zhengshi = SignatureKeyManager.getSignatureKey()
//    print("密钥: \(zhengshi)")
//
//    // 第1步：定义测试密钥
//    let testKey = "v5b8c7d6e3f2g1r0i9j8k7l6m5n4o3ps"
//    print("测试密钥: \(testKey)")
//    print("密钥长度: \(testKey.count)字符")
//    print("-------------------")
//
//    // 第2步：测试简单混淆/解混淆功能
//    print("测试简单混淆/解混淆:")
//    let samplePart = "a5b8"
//    let obfuscated = SignatureKeyManager.applySimpleObfuscation(samplePart)
//    let recovered = SignatureKeyManager.reverseSimpleObfuscation(obfuscated)
//
//    print("原始部分: \"\(samplePart)\"")
//    print("混淆后: \"\(obfuscated)\"")
//    print("恢复后: \"\(recovered)\"")
//    print("匹配结果: \(samplePart == recovered ? "✓ 成功" : "✗ 失败")")
//    print("-------------------")
//
//    // 第3步：测试生成新的混淆映射
//    print("测试生成新的混淆映射:")
//    let obfuscationResult = SignatureKeyManager.createNewObfuscation(for: testKey)
//
//    print("生成的混淆字符数组:")
//    for (index, part) in obfuscationResult.obfuscatedParts.enumerated() {
//        print("[\(index)]: \"\(part)\"")
//    }
//
//    print("\n生成的洗牌映射:")
//    print(obfuscationResult.shuffleMap)
//    print("-------------------")
//
//    // 第4步：测试完整的恢复过程
//    print("测试完整的恢复过程:")
//
//    // 使用修复后的恢复逻辑
//    let recoveredKey = SignatureKeyManager.testRecovery(
//        originalKey: testKey,
//        obfuscatedParts: obfuscationResult.obfuscatedParts,
//        shuffleMap: obfuscationResult.shuffleMap
//    )
//
//    print("恢复后的密钥: \(recoveredKey)")
//    print("原始密钥: \(testKey)")
//    print("恢复结果: \(recoveredKey == testKey ? "✓ 成功" : "✗ 失败")")
//
//    if recoveredKey != testKey {
//        print("\n检查失败原因:")
//        for (index, (original, recovered)) in zip(testKey, recoveredKey).enumerated() {
//            if original != recovered {
//                print("位置 \(index): 原始'\(original)' ≠ 恢复'\(recovered)'")
//            }
//        }
//    }
//    print("-------------------")
//
//    // 第5步：生成更新代码
//    print("生成密钥更新代码:")
//    let updateCode = SignatureKeyManager.updateSignatureKey(newKey: testKey)
//    print(updateCode)
//    print("-------------------")
//
//    // 第6步：模拟实际使用场景
//    print("模拟实际使用场景:")
//
//    // 这里假设我们已经用生成的映射更新了SignatureKeyManager
//    // 为了模拟，我们使用testRecovery方法
//    let finalKey = recoveredKey
//    print("最终生成的密钥: \(finalKey)")
//    print("原始密钥: \(testKey)")
//    print("实际使用结果: \(finalKey == testKey ? "✓ 成功" : "✗ 失败")")
//    print("-------------------")
//
//    print("测试完成!")
//}
