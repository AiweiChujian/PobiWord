# 项目架构（iOS / SwiftUI / SwiftPM）

## 1. 分层设计、职责与依赖

本项目采用「Xcode App + Swift Package 模块化」架构。当前仓库的核心分层如下：

- `AppMain`（应用装配层 / Composition Root）
  - 应用入口（`AppDelegate`、`SceneDelegate`）。
  - 创建全局 `AppRouter`，并触发各 Feature 的 `Coordinator.registerRoutes(in:)`。
  - 只做装配，不承载具体业务状态与业务规则。

- `MainDependence`（聚合依赖层）
  - 聚合 App 目标依赖的 Feature Package（如 `AppHome`、`AppProfile`）。
  - 仅做依赖编排，不放业务实现。

- `AppFeatures/*`（业务功能层）
  - 业务 Feature 包（如 `AppHome`、`AppProfile`）。
  - 每个 Feature 内以 `Coordinator + Router + ViewModel + View` 组织页面与导航。
  - 业务页面统一遵循 `MVVM + Redux`（详见 `architecture_pattern.md`）。

- `AppFeatures/AppUI`
  - 提供跨 Feature 复用的 UI、路由与架构基建。
  - 典型能力：`AppRouter`、`AppRouteKey`、`RootTabView`、`MVVMRedux.swift`。
  - 不承载具体业务页面逻辑。

- `AppServices/*`（服务与基础能力层）
  - 复用服务能力（如 `AppFoundation`、`AppNetwork`、`AppLog`）。
  - 其中 `AppServices/AppFoundation` 是 Service 基础能力底座，对应 `app_service_base`。
  - 对上游提供稳定 API，不依赖 Feature 页面实现。

- `AppData`（数据模型层）
  - 数据模型、基础类型、持久化数据对象。
  - 不包含 UI、路由与 Feature 业务编排逻辑。

- `LocalPackages/*`（跨项目复用资产层）
  - 本地通用包（如 `BaseKit`、`SwiftUIRouter`、`SwiftEntryKit`）。
  - 用于收集/归档经过验证、可跨项目复用的代码或方案，可被 `AppUI`/`AppServices`/`AppData` 依赖。

### 依赖约束

- 只允许高层依赖低层，禁止反向依赖。
- Feature 之间禁止直接 import；跨 Feature 访问统一走 `AppRouteKey + GlobalRouter`。
- `AppMain` 仅装配，不实现 Feature 内部业务逻辑。
- 共享 UI/架构能力统一下沉到 `AppFeatures/AppUI`，不要在多个 Feature 重复实现。
- Service 通用底座能力优先沉淀在 `AppServices/AppFoundation`（`app_service_base` 对应层），避免散落在 Feature 内或重复建设。
- `LocalPackages/*` 用于沉淀可跨项目复用的代码或方案规范，不用于承载当前项目特有业务逻辑。

## 2. `AppServices/*` 模块开发规范

### 模块边界

- 每个 Service 使用 SwiftPM 标准结构：`Package.swift` + `Sources/` + `Tests/`。
- 对外仅暴露必要 public API，内部实现保持封装。
- 避免在 Service 中引入页面、路由、`View`、`Coordinator` 等 UI 层对象。

### 依赖约束

- Service 层可以依赖 `AppData`、`LocalPackages/*` 或其他 Service。
- Service 层禁止依赖任何 `AppFeatures/*` 业务模块。

### 测试约束

- 公开 API 至少覆盖正常路径与关键边界场景。
- 对外行为变化时必须同步更新测试，保证上游契约稳定。
- 测试代码中的每个测试项都应包含中文注释，说明测试内容与预期结果。

### README 约束

- 当前仓库中部分 Service 尚未提供 README。
- 当你新增 Service 或变更公开 API 时，需在对应 Package 根目录新增或更新 `README.md`，明确用途、依赖和对外 API。

## 3. `AppFeatures/*` 模块开发规范

### 路由与导航

每个 Feature 基于 SwiftUIRouter 库，实现本地与全局路由的导航（详见 `architecture_pattern.md`）。

### 路由 Key 管理

- 所有可导出路由统一定义在 `AppFeatures/AppUI/Sources/AppUI/AppRouter/AppRouteKey.swift`。
- 新增路由时必须同步更新 `AppRouteKey` 与对应 Feature Router 的 `exportedPaths`。
- 禁止在业务代码中硬编码跨模块路由字符串。

### 页面架构统一

- Feature 页面统一采用 `MVVM + Redux`（详见 `architecture_pattern.md`）。
- `View` 负责渲染与事件分发；`ViewModel` 负责动作归约与状态维护；副作用通过 `CommandEffect` 或 `routeDelegate` 执行。

### 代码组织建议

- Feature 内建议按页面或子域组织：`Views/`、`ViewModels/`、`Coordinator.swift`、`Router.swift`。
- 公共 UI 或跨 Feature 复用逻辑优先放入 `AppUI`，避免复制。

### 测试约束

- 每个 `ViewModel` 的关键 `ViewAction` 都应有测试覆盖。
- 当 `ViewAction`、导航行为、状态字段或副作用流程变化时，必须同步更新测试。
- 测试代码中的每个测试项都应包含中文注释，说明测试内容与预期结果。

### README 约束

- 当前仓库中部分 Feature 尚未提供 README。
- 当你新增 Feature、页面路由或重要公开能力时，需在对应 Feature Package 根目录新增或更新 `README.md`。
