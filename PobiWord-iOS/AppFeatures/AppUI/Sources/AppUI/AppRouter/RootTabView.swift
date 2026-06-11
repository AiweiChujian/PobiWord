import SwiftUI

public struct RootTabView: View {
    @EnvironmentObject private var router: AppRouter

    public init() {}

    public var body: some View {
        TabView(selection: $router.selectedTab) {
            ForEach(router.tabs) { tab in
                router.tabView(for: tab)
            }
        }
    }
}
