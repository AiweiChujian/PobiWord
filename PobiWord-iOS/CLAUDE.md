# CLAUDE.md

本文件定义 Agent 在本仓库中执行编程任务时必须遵守的工作规则。除非用户明确要求偏离，否则所有实现、修改、重构、补测与文档更新都必须遵循以下约束。

## 1. 渐进式披露规则

Agent 应根据任务类型按需读取架构文档，避免一次性加载所有文档：

- **必读**：在开始任何编程任务前，必须先读取 `AGENTS/project_architecture.md`，理解当前任务涉及的分层设计、模块职责与依赖约束。
- **按需读取**：当任务涉及 Feature 页面的 UI 开发（新增或修改 View、ViewModel、State、Action、Effect）时，还需读取 `AGENTS/architecture_pattern.md`，理解 `mvvm + redux` 架构模式的部件定义与实施约束。
- 如果用户请求与架构文档中的规则冲突，Agent 不得直接执行冲突方案；应先明确指出冲突点，并给出符合架构约束的替代实现。
- 在提出方案、编写代码、补充测试、调整目录结构前，都应以架构文档作为首要依据，避免凭经验绕过既有架构。


## 2. 模块落点规则

- 实现代码时必须先判断目标改动属于 `AppMain`、`MainDependence`、`AppFeatures/*`、`AppFeatures/AppUI`、`AppServices/*`、`AppServices/AppFoundation`（`app_service_base` 对应层）或 `AppData` 中的哪一层，再决定落点。具体定义详见 `AGENTS/project_architecture.md`。
- 当 Agent 发现某段代码会造成 Feature 间直接依赖、职责漂移或重复实现时，应优先下沉到 `AppFeatures/AppUI`（共享 UI/路由/架构）或 `AppServices/AppFoundation`（Service 基础能力底座）解决；`LocalPackages/*` 用于收集/归档经过验证、可跨项目复用的代码或方案。

## 3. Feature 开发规则

- 修改或新增 Feature 代码前，应先确认该 Feature Package 是否已有 `README.md`；若没有且本次改动引入了新路由、公开能力或关键约束，应补充 README。
- Feature 的路由与导航规范、页面架构要求、代码组织方式与测试约束详见 `AGENTS/project_architecture.md` 第 3 节。
- Feature 页面的 `mvvm + redux` 架构模式详见 `AGENTS/architecture_pattern.md`。

## 4. Service 开发规则

- 修改或新增 Service 代码前，应先确认对应 Service Package 是否已有 `README.md`；若没有且本次改动涉及公开 API，应补充 README 并说明用途与依赖。
- Service 的模块边界、依赖约束与测试约束详见 `AGENTS/project_architecture.md` 第 2 节。

## 5. 测试规则

- 只要修改了公开 API、`Action`、`State`、ViewModel 行为、Service 行为或跨模块契约，就必须同步检查并更新测试。
- 测试代码中的每个测试项都应添加中文注释，明确说明测试内容和预期结果。
- 若本次改动影响了对外行为，但无法补齐测试，Agent 必须明确说明缺失项和风险，不能默认略过。
- 各模块的具体测试覆盖要求详见 `AGENTS/project_architecture.md` 中对应模块的测试约束。

## 6. 文档与交付规则

- 当新增 Feature、Service、公开 API、关键路由、重要架构约束或明显改变模块职责时，应同步更新相应 `README.md` 或相关说明文档。
- 如果实现过程中发现架构文档本身存在歧义、缺漏或与当前代码现实不一致，Agent 应先按现有文档执行，同时在结果中指出差异，必要时建议用户同步更新架构文档。
- Agent 的实现说明应明确指出本次改动如何遵循架构文档，尤其是在模块落点、依赖方向、路由方式（`AppRouteKey + Coordinator/Router`）和测试补充方面。

## 7. GSD 工作流约束（适用于主 Agent 及所有子 Agent）

以下规则在执行任何 `/gsd:*` 命令、GSD 子 Agent（如 gsd-executor、gsd-planner、gsd-roadmapper 等）运行期间，以及处理 `.planning/` 目录下任何文件时，均强制生效。任何 GSD 内部默认行为若与本节规则冲突，以本节为准。

### 7.1 `.planning/` 目录禁止纳入版本控制

- `.planning/` 目录内容禁止纳入 git 追踪（即使本仓库当前 `.gitignore` 尚未显式声明，也必须按此规则执行）。
- 即使 GSD 工作流要求提交 `.planning/` 下的文件（如 STATE.md、SUMMARY.md、ROADMAP.md），也必须跳过，不得执行对应的 git add / git commit。
- 若发现 `.planning/` 下的文件被意外追踪，应立即用 `git rm -r --cached .planning/` 清理。

### 7.2 GSD 产出语言必须为中文

- GSD 工作流产出的所有文件（PROJECT.md、ROADMAP.md、STATE.md、PLAN.md、SUMMARY.md、RESEARCH.md 等）必须使用中文撰写。
- GSD 子 Agent 生成的计划、摘要、验证报告等文本内容同样必须使用中文。
- 代码中的标识符（变量名、函数名、类名）保持英文，仅注释和文档使用中文。
