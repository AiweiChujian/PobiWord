# WordPlanService

`WordPlanService` 是单词学习计划领域的 Service 模块，为上层 Feature 提供稳定的业务能力入口。

## 环境

- Swift tools 6.2
- Swift 6 语言模式
- iOS 17+
- Package 内的生产代码和测试代码均以 `MainActor` 作为默认隔离域

## 依赖

当前模块依赖 `AppFoundation`，并通过它使用 Service 层基础能力。模块不依赖任何 Feature。

## 对外 API

```swift
import WordPlanService

let service = WordPlanService()
```

`WordPlanService` 是学习计划能力的统一入口。后续业务 API 应继续保持必要最小化，并为所有公开行为补充 Swift Testing 测试。
