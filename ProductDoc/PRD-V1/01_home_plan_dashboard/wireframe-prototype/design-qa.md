# Design QA：Pobi 首页 H-03A 视觉方向反向落地

- source visual truth path: `/Users/avery/Desktop/WORK/PobiWord/ProductDoc/PRD-V1/01_home_plan_dashboard/wireframe-prototype/qa-artifacts/h-03a-visual-direction-final.png`
- implementation screenshot path: `/Users/avery/Desktop/WORK/PobiWord/ProductDoc/PRD-V1/01_home_plan_dashboard/wireframe-prototype/qa-artifacts/h-03a-review.png`
- H-02 screenshot path: `/Users/avery/Desktop/WORK/PobiWord/ProductDoc/PRD-V1/01_home_plan_dashboard/wireframe-prototype/qa-artifacts/h-02-new.png`
- H-03B screenshot path: `/Users/avery/Desktop/WORK/PobiWord/ProductDoc/PRD-V1/01_home_plan_dashboard/wireframe-prototype/qa-artifacts/h-03b-learn.png`
- H-01 screenshot path: `/Users/avery/Desktop/WORK/PobiWord/ProductDoc/PRD-V1/01_home_plan_dashboard/wireframe-prototype/qa-artifacts/h-01-empty.png`
- full-view comparison evidence: `/Users/avery/Desktop/WORK/PobiWord/ProductDoc/PRD-V1/01_home_plan_dashboard/wireframe-prototype/qa-artifacts/h-03a-reference-vs-prototype.png`
- viewport: `390 × 844`，iOS 移动画板
- primary state: `H-03A 有学习记录 / 当前应复习`
- derived states: `H-02 有计划无记录`、`H-03B 有记录当前应学习`

## Findings

- 未发现仍需处理的 P0、P1 或 P2 问题。
- [P3] 锁定方向图中的三个 Section 比最终实现略高。
  - Location：H-03A 仪表盘、入口、Activity。
  - Evidence：并排图左侧为初始视觉方向，右侧实现按用户最后数轮反馈收紧了仪表盘内容、入口垂直间距和 Activity 底部边距。
  - Impact：属于已确认的密度优化；实现更接近最终要求，并让三个核心区域完整落在首屏。
  - Fix：不修改，保留当前紧凑比例。
- [P3] 复习图标与方向图中的自定义双语卡片细节不同。
  - Location：`.review-symbol`。
  - Evidence：方向图为 A/文双卡片，原型使用同一 Phosphor 图标家族的 `CardsThree + ArrowsClockwise`。
  - Impact：复习语义、圆形材质和视觉权重一致，同时避免用手绘 SVG 或 CSS 图形伪造资产。
  - Fix：Figma 视觉稿阶段可基于 SF Symbols 进一步定制正式 Pobi 图标；当前原型无需阻塞。

## Open Questions

- 无阻塞问题。当前深色方向作为 H-02、H-03A、H-03B 的统一视觉基准；浅色模式后续应由语义色令牌派生，不在本轮原型范围内。

## 必检维度

- 字体与排版：使用 iOS 系统字体与苹方回退；阶段标题、主数字、单位、说明和按钮层级清晰。H-02/H-03B 文案均未截断，圆环总数独立换行显示。
- 间距与布局：三个有计划状态均为“仪表盘 → 主入口 → Activity（如适用）”；仪表盘高 160 px、入口高 192 px、Activity 高 176 px。入口没有额外增加无意义的垂直留白。
- 颜色与令牌：H-03A 使用左下蓝色到右上品红色的复习渐变；H-02/H-03B 使用鲜活绿色到黄色的学习渐变，并与 H-03A 一致使用白色标题、数字、单位、次入口、图标和白色实心主按钮，说明文字为 88% 白色；学习按钮文字使用主题绿色。仪表盘和 Activity 使用 Secondary Background，三个统计 Item 使用各自低对比度 Tertiary Background。
- 图片与资源：页面没有照片或插画资产。所有可见图标均来自 Phosphor 同一图标库，没有 Emoji、文本符号、手绘 SVG、内联 SVG 或 CSS 图标替代。
- 文案与内容：H-03A 为“本轮复习 / 开始复习 / 巩固学习”；H-02/H-03B 为“本轮学习 / 开始学习”，H-03B 增加“强化复习”。日期均使用 `yyyy-MM-dd`。
- 图标：复习图标由卡片与循环箭头组成；学习图标由打开的书和闪光组成。两种图标容器实测均为 `88 × 88`，保持正圆。
- Activity：H-02 不渲染 Activity；H-03A/H-03B 均为 12 列 × 5 行，共 60 格，且包含灰、暗绿、浅绿、亮绿四级语义。
- H-01 视觉统一：空状态使用与 H-02/H-03 相同的深色页面和圆形导航按钮，但内容直接置于页面背景，不使用 Section、Secondary Background、边框或眉题；学习图标容器实测 `96 × 96`，主按钮为白底绿色文字。
- 响应与可访问性：375 px 宽度无页面横向溢出，430 px 画板保持 390 px 评审基准；按钮均为语义化 `button`，主要命中区域不小于 44 px，进度使用 `progressbar` 语义。

## 主要交互测试

- 计划标题点击后成功打开 O-01 学习计划菜单。
- 左上角菜单点击后成功打开 O-02 Profile + 设置抽屉。
- 主入口与次入口保留按钮交互和进入流程的反馈。
- H-02、H-03A、H-03B 均可通过 URL 状态直接访问。
- 浏览器控制台 `error` / `warn`：无。

## Comparison History

### Pass 1：结构与状态反向更新

- Earlier findings：旧实现使用“主任务 / 计划概览 / 统计摘要”结构，与锁定视觉方向的“仪表盘 / 主入口 / Activity”不一致；H-02/H-03B 没有共享 H-03A 的视觉体系。
- Fixes made：重构为共享 `PlanDashboard`、`TaskEntry`、`ActivitySection`；H-02 条件隐藏 Activity；H-02/H-03B 增加学习渐变和专属学习图标。
- Post-fix evidence：`h-02-new.png`、`h-03a-review.png`、`h-03b-learn.png`。

### Pass 2：Activity 语义完整性

- Earlier findings：初版 60 天示例数据只覆盖灰、暗绿、亮绿，缺少“完成复习和学习”的浅绿 Level 2。
- Fixes made：调整本地示例矩阵，使四种 Activity 语义均在 12 × 5 网格中出现。
- Post-fix evidence：`h-03a-review.png`、`h-03b-learn.png`，DOM 实测 60 格、12 列。

### Final pass

- H-03A 源图与实现已在同一张 780 × 844 对照图中按 390 × 844 等比例并排检查。
- H-02/H-03B 已按相同布局、间距和组件系统单独截图检查。
- 未发现需继续修复的 P0、P1 或 P2 差异。

## Focused Region Comparison

未额外制作聚焦裁切。原因是对照图为两个 390 × 844 原比例画面并排，仪表盘数字、统计 Item、主入口文案、两个图标系统及 Activity 单格均可清晰辨认；额外放大不改变结论。

## Implementation Checklist

- [x] `ui.md` 已反向更新为锁定视觉结构和状态规则。
- [x] H-02、H-03A、H-03B 共用仪表盘和入口组件。
- [x] H-02/H-03B 共用学习渐变与学习图标。
- [x] H-02 不显示 Activity；H-03A/H-03B 显示 60 天 Activity。
- [x] 计划菜单、侧边栏和任务入口交互保留。
- [x] `npm run build` 通过。
- [x] 390 × 844 浏览器截图、响应式边界和控制台已检查。

## Follow-up Polish

- Figma 正式稿阶段可把复习/学习组合图标沉淀为 Pobi 品牌组件，并输出 SF Symbols 风格矢量资产；原型继续使用图标库版本作为开发占位。

final result: passed
