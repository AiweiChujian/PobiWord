import WordPlanService

/// 单词学习计划 Feature 的装配入口。
public final class WordPlanFeature {
    public let service: WordPlanService

    public init(service: WordPlanService = WordPlanService()) {
        self.service = service
    }
}
