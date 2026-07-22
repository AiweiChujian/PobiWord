# AppFoundation

`AppFoundation` 是 `AppServices` 层的基础能力包，用于提供跨业务模块复用的服务底座能力。当前包含应用上下文、服务端环境、日志封装、网络请求协议与网络响应处理。

## 依赖

- `AppData`：复用数据层基础类型。
- `swift-log`：提供统一日志接口。
- `SwiftyBeaver`：提供日志落盘与日志目的地能力。
- `Alamofire`：提供网络请求、上传、请求适配与响应序列化能力。

## 公开能力

- `AppContext`：读取应用版本、构建号、沙盒状态与系统信息。
- `ServerEnvironment` / `ServerHost`：提供当前环境判断与基础 URL。
- `NetworkRequest`：定义请求参数、URL、授权、上传、Session、Headers、Encoder 与请求修改器。
- `NetworkClient`：根据 `NetworkRequest` 创建普通请求或上传请求。
- `NetworkResponse` / `NetworkError`：封装接口响应数据与错误转换。
- `Logger.setup` 与日志 handler：配置 SwiftLog、SwiftyBeaver 与 OSLog。
- `TimeCost`：提供性能打点与耗时日志。

## 并发约束

本包使用 Swift 6.2，并将 MainActor 设置为默认隔离域。与 UI 或 UIKit 状态相关的 API 保持默认 MainActor 隔离；网络协议、网络执行、错误类型、响应类型、日志 handler 和环境基础能力等不需要主线程语义的类型/API 显式标注为 `nonisolated`。

网络响应与请求参数会跨异步边界传递，因此 `NetworkParameters` 需要满足 `Sendable`，`NetworkRequest.Params` 需要满足 `Encodable & Sendable`，`NetworkResponse.Base` 的数据类型需要满足 `Codable & Sendable`。
