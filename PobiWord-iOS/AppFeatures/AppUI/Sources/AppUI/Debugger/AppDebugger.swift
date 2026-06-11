//
//  File.swift
//  AppUI
//
//  Created by Avery on 2025/4/27.
//

import Foundation
import DebugSwift
import AppFoundation
import Alamofire

extension DebugSwift: @unchecked @retroactive Sendable {}

@MainActor
public final class AppDebugger: Sendable {
    private static let shared = AppDebugger()
    
    private init() {}
    
    private static var shouldShowDebugger: Bool  {
#if DEBUG
        return true
#else
        return ServerEnvironment.isDevelopment
#endif
    }
    
    private let debugger = DebugSwift()
    
    public static func setup() {
        guard shouldShowDebugger else {
            return
        }
        shared.setup()
    }
}

extension AppDebugger: @preconcurrency CustomHTTPProtocolDelegate {
    public func urlSession(_ protocol: URLProtocol, _ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        Session.default.session.getAllTasks { tasks in
            let uploadTask = tasks.first(where: { $0.taskIdentifier == task.taskIdentifier }) ?? task
            Session.default.rootQueue.async {
                Session.default.delegate.urlSession(
                    session,
                    task: uploadTask,
                    didSendBodyData: bytesSent,
                    totalBytesSent: totalBytesSent,
                    totalBytesExpectedToSend: totalBytesExpectedToSend
                )
            }
        }
    }
}

extension AppDebugger {
    /// 对调试工具进行初始化
    private func setup() {
        // To fix Alamofire `uploadProgress`
        DebugSwift.Network.shared.delegate = self

        let tools: [CustomAction.Action] = []
//        let tools: [CustomAction.Action] = Tools.allCases.map {
//            .init(title: $0.title, action: $0.entryPoint)
//        }
        DebugSwift.App.shared.customAction = {[
            .init(title: "自定义工具", actions: tools),
        ]}
        

        debugger.setup(disable: [
//            .network,
//            .crashManager,
            .location,
            .views,
            .leaksDetector,
            .console
        ])
        debugger.show()
    }
}
