# Feature Coordinator 与 Router 开发指南

本文档基于 `SwiftUIRouter` 库，描述一个 Feature 如何创建并接入自己的 `Coordinator` 与 `Router`。

## 1. 适用范围

以下场景必须遵循本指南：

- 新增 Feature，首次接入导航。
- 既有 Feature 新增页面路由（含跨模块可达路由）。
- 调整 `Coordinator` / `Router` 结构、路由注册方式或全局路由协作方式。

## 2. 标准流程

### 步骤 1：先定义路由 Key（跨模块可达时必做）

- 在 `AppFeatures/AppUI/Sources/AppUI/AppRouter/AppRouteKey.swift` 中新增枚举值。
- `AppRouteKey` 只承载“可导出、可被全局路由访问”的路由。
- 仅模块内使用、无需跨模块访问的路由，不加入 `AppRouteKey`。

### 步骤 2：为 Feature 创建本地 `Router`

`Router` 负责本模块路由定义与导出，推荐模板如下：

```swift
import AppUI

@MainActor
public final class Router: ExportableRouter {
    public typealias RouteKey = AppRouteKey

    public let appWindow: UIWindow

    public init(appWindow: UIWindow) {
        self.appWindow = appWindow
    }

    @Route var featureDetail = makeFeatureDetailView

    public var exportedPaths: [AppRouteKey: ExportableRoutePath] {
        [
            .featureDetail: featureDetail
        ]
    }
}

extension Router {
    func makeFeatureDetailView(id: String) -> some View {
        FeatureDetailView(id: id)
    }
}
```

实现要点：

- `Router` 必须实现 `ExportableRouter`，并指定 `RouteKey = AppRouteKey`。
- 使用 `@Route` 声明路由入口；通过 `exportedPaths` 决定哪些路由对全局可见。

### 步骤 3：为 Feature 创建 `Coordinator`

`Coordinator` 是 Feature 的路由装配入口，推荐模板如下：

```swift
import AppUI

@MainActor
public final class Coordinator: FeatureCoordinator, ReduxRouteDelegate {
    public static var shared: Coordinator!

    public let global: AppRouter
    public let router: Router

    private init(global: AppRouter) {
        self.global = global
        self.router = Router(appWindow: global.appWindow)
    }

    public static func registerRoutes(in global: AppRouter) {
        let coordinator = Coordinator(global: global)
        shared = coordinator

        global.register(coordinator.router)

        global.registerTab(.feature) {
            FeatureRootView()
                .tabItem { Label("Feature", systemImage: "square.grid.2x2") }
        }
    }
}
```

实现要点：

- `registerRoutes(in:)` 内必须完成三件事：
  - 创建并保存 `shared`。
  - `global.register(coordinator.router)` 导出本地路由到全局。
  - 需要 Tab 时调用 `global.registerTab(...)` 注册根入口。
- 不需要 Tab 的 Feature，可省略 `registerTab`，但仍需完成路由注册。

### 步骤 4：在 ViewModel 与 Coordinator 之间建立路由代理协议

```swift
import AppUI
import SwiftUI

@MainActor
protocol FeatureRouteDelegate: ReduxRouteDelegate {
    func pushLocalDetail(_ id: String)
    func pushProfileDetail(_ userId: String)
}

extension Coordinator: FeatureRouteDelegate {
    func pushLocalDetail(_ id: String) {
        router.push(\.featureDetail, id)          // 本地路由
    }

    func pushProfileDetail(_ userId: String) {
        global.push(.profileDetail, userId)       // 全局路由（跨模块）
    }
}

@MainActor @Observable
final class FeatureViewModel: ReduxViewModel {
    weak var routeDelegate: Coordinator?

    init(routeDelegate: Coordinator? = .shared) {
        self.routeDelegate = routeDelegate
    }
}
```

实现要点：

- `ViewModel` 只依赖 `routeDelegate` 抽象，不直接操作 `AppRouter` / `UIWindow`。
- 本模块页面跳转走 `router.push(...)`；跨模块跳转走 `global.push(.routeKey, input)`。
- `routeDelegate` 保持 `weak`，避免循环引用。

### 步骤 5：在 `AppMain` 装配 Feature

在 `AppMain/AppMain/SceneDelegate.swift` 中注册全部 Feature：

```swift
let router = AppRouter(windowScene)

AppHome.Coordinator.registerRoutes(in: router)
AppProfile.Coordinator.registerRoutes(in: router)

router.makeRootAndVisible()
window = router.appWindow
```

实现要点：

- 任何需要响应全局路由的 Feature，都必须在 `SceneDelegate` 装配阶段执行 `registerRoutes(in:)`。
- 若遗漏注册，`global.push(.someRoute, ...)` 会因路由未注册而失败（断言提示）。

## 3. 全局路由与本地路由协作原则

- 本地优先：同 Feature 内页面跳转优先走本地 `Router`，避免无意义绕行全局路由。
- 跨模块统一入口：跨 Feature 页面访问统一走 `AppRouteKey + AppRouter`。
- 导出最小化：仅将跨模块需要访问的路由加入 `exportedPaths`。
- 依赖隔离：禁止通过直接 import 其他 Feature 来获取页面类型并导航。

## 4. 常见错误与排查

- 忘记 `global.register(coordinator.router)`：
  - 现象：`global.push` 找不到目标路由。
- 忘记更新 `AppRouteKey` 或 `exportedPaths`：
  - 现象：跨模块跳转不可达或输入类型不匹配。
- 忘记设置 `Coordinator.shared`：
  - 现象：`ViewModel` 默认 `routeDelegate` 为 `nil`，导航无响应。
- 在 ViewModel 中直接持有全局路由或 UIKit 控制器：
  - 现象：分层被破坏，测试与复用变差。

## 5. 验收清单

- 已创建 `Coordinator.swift` 与 `Router.swift`，并满足 `FeatureCoordinator` / `ExportableRouter` 协议。
- `registerRoutes(in:)` 已完成路由导出与（如需要）Tab 注册。
- 新增跨模块路由已同步更新 `AppRouteKey`。
- ViewModel 导航动作均通过 `routeDelegate` 发起。
- `SceneDelegate` 已装配该 Feature 并在应用启动时注册。
