//
//  File.swift
//  BaseKit
//
//  Created by Avery on 2025/4/28.
//

import Foundation

public extension FileManager {
    var documentDirectory: URL {
        urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var cachesDirectory: URL {
        urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }
    
    var tempDirectory: URL {
        temporaryDirectory
    }
    
    static let documentDirectory: URL = FileManager.default.documentDirectory
    
    static let cachesDirectory: URL = FileManager.default.cachesDirectory
    
    static let tempDirectory: URL = FileManager.default.tempDirectory
}

public extension FileManager {
    @discardableResult
    static func guardDirectoryIsExist(_ url: URL, force: Bool = true) -> Bool {
        self.default.guardDirectoryIsExist(url, force: force)
    }
    
    @discardableResult
    func guardDirectoryIsExist(_ url: URL, force: Bool = true) -> Bool {
        var isDirectory: ObjCBool = false
        
        var isExist = fileExists(atPath: url.path, isDirectory: &isDirectory)
        do {
            if isExist, !isDirectory.boolValue {
                guard force else { return false }
                try removeItem(at: url)
                isExist = false
            }
            if !isExist {
                try createDirectory(at: url, withIntermediateDirectories: true)
            }
            return true
        } catch  {
            assertionFailure("Create Directory path(\(url.path)) error: \(error.localizedDescription)")
            return false
        }
    }
}


public extension FileManager {
    // 根据path获取完成路径
    @discardableResult
    static func getFileFullPath(_ path: String) -> String {
        NSHomeDirectory() + "/Library/" + path
    }
    // 根据path创建路径需要创建文件夹
    @discardableResult
    static func createFullPath(_ path: String) throws -> String {
        let fullPath = getFileFullPath(path)
        let manager = FileManager.default
        if !manager.fileExists(atPath: fullPath) {
            do {
                try manager.createDirectory(atPath: fullPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                throw error
            }
        }
        return fullPath
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
            throw error
        }
        return true
    }
    
    static func createTempFilePath(fileName: String) -> String {
        let fileManager = FileManager.default
        let file = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        let path = file! + "/" + fileName
        if fileManager.fileExists(atPath: path) {
            try? fileManager.removeItem(atPath: path)
        }
        fileManager.createFile(atPath: path, contents:nil, attributes:nil)
        return path
    }
}

public extension FileManager {
    func getUniqueFilePath(fileName: String) -> URL? {
        // 获取 libraryDirectory Directory 的路径
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            assertionFailure("fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first fail")
            return nil
        }
        
        // 创建 files 文件夹的路径
        let filesDirectory = documentDirectory.appendingPathComponent("files")
        
        // 如果 files 文件夹不存在，则创建它
        if !fileManager.fileExists(atPath: filesDirectory.path) {
            do {
                try fileManager.createDirectory(at: filesDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                assertionFailure("getUniqueFilePath: createDirectory fail: \(error)")
                return nil
            }
        }
        
        // 检查文件名是否已存在
        var uniqueFileName = fileName
        var filePath = filesDirectory.appendingPathComponent(uniqueFileName)
        
        var index = 1
        while fileManager.fileExists(atPath: filePath.path) {
            // 如果文件已存在，则在文件名后添加索引
            let fileExtension = (fileName as NSString).pathExtension
            let nameWithoutExtension = (fileName as NSString).deletingPathExtension
            uniqueFileName = "\(nameWithoutExtension)(\(index)).\(fileExtension)"
            filePath = filesDirectory.appendingPathComponent(uniqueFileName)
            index += 1
        }
        
        return filePath
    }
}
