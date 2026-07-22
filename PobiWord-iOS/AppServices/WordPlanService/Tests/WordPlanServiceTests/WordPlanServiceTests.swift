import Testing
@testable import WordPlanService

@Suite("WordPlanService")
struct WordPlanServiceTests {
    /// 验证服务可以在默认的 MainActor 隔离域中正常创建。
    @Test("可以创建服务实例")
    func createsServiceOnMainActor() {
        _ = WordPlanService()
    }
}
