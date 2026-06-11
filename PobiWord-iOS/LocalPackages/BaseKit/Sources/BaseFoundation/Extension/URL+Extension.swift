//
//  File.swift
//  BaseKit
//
//  Created by Avery on 2025/7/2.
//

import Foundation
import UniformTypeIdentifiers
import CryptoKit

public extension URL {
    static func fetchImageURL(uid: String, searchPath: FileManager.SearchPathDirectory = .libraryDirectory) -> URL {
        let name = String(format: "%@.jpeg", UUID().uuidString)
        return fetchFileURL(appendingPath: nil, uid: uid, searchPath: .libraryDirectory).appendingPathComponent(name)
    }
    static func fetchFileURL(appendingPath: String?, uid: String, searchPath: FileManager.SearchPathDirectory = .libraryDirectory) -> URL {
        let dir = NSSearchPathForDirectoriesInDomains(searchPath, .userDomainMask, true)[0]
        let dirUrl = URL.init(fileURLWithPath: dir)
        let userDirUrl = dirUrl.appendingPathComponent(uid, isDirectory: true)
        if FileManager.default.fileExists(atPath: userDirUrl.path) == false {
            try? FileManager.default.createDirectory(at: userDirUrl, withIntermediateDirectories: true)
        }
        if let appendingPath = appendingPath, appendingPath.count > 0 {
            let newUserDirUrl = userDirUrl.appendingPathComponent(appendingPath, isDirectory: true)
            if FileManager.default.fileExists(atPath: newUserDirUrl.path) == false {
                try? FileManager.default.createDirectory(at: newUserDirUrl, withIntermediateDirectories: true)
            }
            return newUserDirUrl
        }
        return userDirUrl
    }
    
    
    // 将文件路径下文件拷贝到另一个文件路径下
    @discardableResult
    static func copyFile(fromPath fpath: String, to tpath: String) throws -> Bool {
        let manager = FileManager.default
        guard fpath.count > 0, tpath.count > 0 else {
            return false
        }
        do {
            if manager.fileExists(atPath: tpath) {
                try manager.removeItem(atPath: tpath)
            }
            try manager.copyItem(atPath: fpath, toPath: tpath)
        } catch {
            return false
        }
        return true
    }
}

public extension URL {
    func sizeOfFile() -> Int64 {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path) else {
            return 0
        }
        return (attrs[.size] as? Int64) ?? 0
    }
    
    func bookmarkData() throws -> Data {
        let bookmarkData = try bookmarkData(options: .withoutImplicitSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        return bookmarkData
    }
}
