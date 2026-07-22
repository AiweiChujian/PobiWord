import Testing
@testable import WordPlan

@Suite("WordPlanFeature")
struct WordPlanFeatureTests {
    /// 验证 Feature 默认装配 WordPlanService，并能正常创建。
    @Test("可以创建默认 Feature")
    func createsDefaultFeature() {
        _ = WordPlanFeature()
    }
}
