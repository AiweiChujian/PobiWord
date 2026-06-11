//
//  Router+Print.swift
//  MVVMRedux
//
//  Created by Avery on 2026/2/10.
//

import Foundation

extension Router {
    public var isEmpty: Bool {
        nodeStackInfo.count == 0 || (nodeStackInfo.count == 1 && nodeStackInfo[0].count == 0)
    }

    public var nodeStackInfo: [[String]] {
        var nodeMatrix: [[String]] = []
        if !assistant.presentedTitles.isEmpty {
            nodeMatrix.append(assistant.presentedTitles)
        }
        var router: (any Router)? = self
        while let r = router {
            var nodes = r.navigationNodes.map(\.title)
            if let root = r.rootTitle {
                nodes.insert(root, at: 0)
            }
            nodeMatrix.append(nodes)
            router = r.last
        }
        return nodeMatrix
    }
}

extension Router {
    /// 打印路由器中的节点
     public var description: String {
        let nodeMatrix = nodeStackInfo
        var desc = ""
        for nodes in nodeMatrix {
            desc.append("\n\(nodes)")
        }
        return desc
    }
}

// MARK: - Router Chain
public extension Router {
    /// 上一个路由器
    var last: (any Router)? {
        assistant.last
    }

    /// 根节点标题
    var rootTitle: String? {
        assistant.rootTitle
    }
}
