# 架构模式（MVVM + Redux，基于 `MVVMRedux.swift`）

本文档描述当前 iOS 项目 Feature 页面统一采用的 `MVVM + Redux` 架构模式。所有 Feature 页面开发必须遵循本文档及 `AppFeatures/AppUI/Sources/AppUI/MVVMRedux.swift` 的实现约束。

## 1. 架构部件

- `ReduxViewModel`
  - 协议定义：`send(_:)`、`reduce(_:) -> Effect?`、`routeDelegate`。
  - 负责接收 `ViewAction`，在 `reduce` 中处理状态更新与副作用分发。
  - `send(_:)` 的默认实现会执行 `reduce` 返回的 `Effect`，并将 `Effect.execute()` 返回的下一个 action 继续递归发送。

- `ViewAction`
  - 对用户交互或系统事件的语义化描述。
  - `View` 与 `ViewModel` 之间唯一的事件输入通道。

- `CommandEffect`
  - 异步副作用基类（`CommandEffect<T: ReduxViewModel>`）。
  - 持有 `weak viewModel`，通过 `execute() async -> ViewAction?` 执行副作用并可返回下一步 action。

- `ReduxRouteDelegate`
  - 路由代理标记协议。
  - 具体导航能力由 Feature 内的 `RouteDelegate` 协议扩展定义，并由 `Coordinator` 实现。

- `ReduxView`
  - 视图协议，要求实现 `viewModel` 与 `reduxBody`。
  - 默认 `body` 会将 `viewModel` 注入 `environmentObject`，页面关注渲染与事件分发。

## 2. 标准落地方式

### 2.1 页面结构建议

- `Views/*View.swift`：SwiftUI 渲染层，仅负责显示和发送 action。
- `ViewModels/*ViewModel.swift`：实现 `ReduxViewModel`，定义 `ViewAction` 与 `reduce`。
- `Coordinator.swift`：实现页面需要的路由代理协议，承接导航意图。
- `Router.swift`：Feature 内部与可导出路由定义（`ExportableRouter`）。

### 2.2 ViewModel 组织建议

- ViewModel 推荐使用 `@MainActor` 与 `@Observable`。
- 页面中通过 `@StateObject` 持有 ViewModel，避免重复创建。
- `routeDelegate` 必须是 `weak`，防止循环引用。
- 当前模式不强制独立 `State` 类型；可直接以 ViewModel 属性承载页面状态。

### 2.3 副作用组织建议

- 简单导航可直接在 `reduce` 中通过 `routeDelegate` 调用。
- 异步请求、串行流程、需要回传下一步 action 的逻辑，使用 `CommandEffect` 子类封装。
- 不要在 `View` 中直接编排异步业务流程。

## 3. 实施约束

- `View` 层只做渲染与事件分发，不直接操作全局路由或服务编排流程。
- 导航统一走 `routeDelegate/Coordinator`，不要在 ViewModel 中直接依赖 UIKit 路由细节。
- `reduce` 应保持可预测，优先处理动作归约；复杂副作用下沉到 `CommandEffect`。
- 跨 Feature 导航统一通过全局路由 `AppRouter + AppRouteKey`，不要直接依赖其他 Feature 模块实现。
- Service 基础能力依赖优先经由 `AppServices/AppFoundation`（`app_service_base` 对应层）提供，避免在 Feature 页面层直接拼装基础设施细节。
- `LocalPackages/*` 仅承载经过验证、可跨项目复用的代码或方案；不要把当前项目特有页面业务规则放入其中。
- 所有公开行为变化（`ViewAction`、路由动作、副作用流程）都必须同步更新测试。

## 4. 复杂列表架构（父 ViewModel + 子 ViewModel）

当列表页中的单个 item 已不再只是简单的数据展示，而是具备明确的局部交互复杂度时，允许在页面级 `ViewModel` 之下继续引入 item 级 `ViewModel`（下文简称“子 ViewModel”），形成“父 ViewModel + 子 ViewModel”的分层协作模式。

该模式仍然属于当前仓库的 `MVVM + Redux` 页面架构扩展，而不是额外引入新的业务入口或路由层。页面级导航仍统一经由 `routeDelegate + Coordinator` 执行；当 item 交互天然拥有明确的跳转意图时，父 ViewModel 也可以将同一份 `routeDelegate` 注入子 ViewModel，由子 ViewModel 直接发起路由动作。

### 4.1 适用场景

满足以下任一情况时，可考虑为列表 item 拆分子 ViewModel：

- item 需要根据多个业务阶段或状态切换不同交互 UI；
- item 内部存在独立的展开 / 收起、局部 loading、局部错误、二次确认等视图状态；
- item 内含独立事件流、异步行为、轮询、倒计时、上传 / 重试等过程型逻辑；
- 若继续将所有 item 逻辑集中在页面级 `ViewModel` 中，会导致条件分支、状态映射和测试复杂度明显上升。

### 4.2 父 ViewModel 职责

采用“父 ViewModel + 子 ViewModel”时，页面级 `ViewModel` 仍然是列表页的主协调者，至少负责以下职责：

- 维护页面级状态。当前项目不强制独立 `State` 类型，因此页面级状态既可以由 `ViewModel` 自身属性承载，也可以由显式的页面快照模型承载；其内容应覆盖全局 loading / empty / error、列表顺序、筛选结果、分页游标、页面级派生信息等；
- 持有子 ViewModel 集合，并将其作为列表渲染数据源的一部分；Swift 代码中通常表现为 `[ItemViewModel]`、`[ItemID: ItemViewModel]` 或两者组合；
- 基于稳定标识（如 `id`、`taskId`）复用、创建、移除和销毁子 ViewModel，保证列表刷新、插入、删除、重排前后 item 身份稳定；
- 接收服务端或上游数据刷新，将最新的不可变业务数据分发给对应子 ViewModel；
- 负责跨 item 协调与列表级业务编排；页面级导航和路由动作不强制只由父 ViewModel 发起，只要父子 ViewModel 都遵循同一套 `routeDelegate/Coordinator` 机制，即可按职责分工分别承担对应跳转；
- 统一管理子 ViewModel 生命周期，避免在 item `View` 内临时创建子 ViewModel 导致状态丢失或重复初始化。

### 4.3 子 ViewModel 职责

子 ViewModel 用于承载单个 item 的局部交互和复杂视图派生，适合负责以下内容：

- item 内部局部 UI 状态，如展开 / 收起、按钮 loading、局部错误提示、确认弹层显隐等；
- 基于不可变业务数据的单 item 视图派生逻辑，如不同 workflow / status 对应的展示文案、操作按钮、辅助标记等；
- item 内部用户事件的接收与处理；如需影响列表级状态或跨 item 协调，应通过父 ViewModel 约定的接口回传，或转化为父 ViewModel 的 `ViewAction` 继续处理；如 item 自身已持有由父 ViewModel 注入的 `routeDelegate`，也允许直接发起该 item 负责的路由跳转；
- item 级资源管理，如局部订阅、定时器、短生命周期异步任务等。

若子 item 本身已经具备清晰的动作归约与副作用流程，子 ViewModel 也可以继续遵循当前仓库的 `ReduxViewModel` 约束，并持有与父 ViewModel 一致的 `routeDelegate`；若仅承担局部状态与简单派生，则可保持为轻量 `@MainActor` `@Observable` 对象，但仍需受父 ViewModel 管理。

### 4.4 状态与数据约束

- 子 ViewModel 可以持有当前 item 对应的不可变业务对象以及 item 局部视图状态，但业务对象本身应保持不可变，并通过整体替换完成更新；
- 父 ViewModel 持有子 ViewModel 集合时，不要求该集合必须再额外包进独立 `State` 结构中做不可变化建模，但必须明确它属于页面渲染层 / 交互层的数据源，而不是独立的路由或业务入口；
- 页面级事实，如列表身份、顺序、全局状态、跨 item 协调结果，仍应由父 ViewModel 统一维护，避免由多个子 ViewModel 分散持有后失去全局一致性；
- 子 ViewModel 不得绕过父 ViewModel 直接承担跨 item 协调或列表编排职责；
- 若父 ViewModel 已将 `routeDelegate` 注入子 ViewModel，则子 ViewModel 可以直接调用路由跳转；但该跳转仍属于页面统一的 `routeDelegate/Coordinator` 机制，子 ViewModel 不应自行持有新的路由入口，也不应直接依赖 UIKit 或其他 Feature 的实现细节；
- 列表渲染时必须使用稳定标识作为 SwiftUI 身份标识，优先采用 `Identifiable` 或 `ForEach(..., id: ...)`，避免因按索引复用导致子 ViewModel 或视图状态错位。

### 4.5 测试约束

- 子 ViewModel 需独立覆盖单 item 在不同业务阶段或状态下的视图派生、局部交互状态流转和 item 内部行为测试；
- 父 ViewModel 需覆盖子 ViewModel 集合的创建 / 复用 / 销毁、列表刷新后的身份稳定性，以及跨 item 协调和页面级动作编排；
- 若子 ViewModel 会向父 ViewModel 回传事件，或会直接调用注入的 `routeDelegate`，还应覆盖父子协作链路，确保不会出现重复派发、状态不同步或路由职责边界错误；
- 测试代码仍需遵循仓库统一要求：每个测试项补充中文注释，明确测试内容与预期结果。
