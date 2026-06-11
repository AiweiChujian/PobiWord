import SwiftUI
import AppUI

struct HomeDetailView: ReduxView {
    @StateObject var viewModel = HomeDetailViewModel()
    @EnvironmentObject private var router: Router
    let id: String

    var reduxBody: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Home Detail")
                .font(.title.bold())

            Text("Item: \(id)")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("来自 AppHome 模块的详情页\n通过 Router (ExportableRouter) 导出\n可被其他模块通过 GlobalRouter 跨模块访问")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            actionButtons

            Spacer()
        }
        .padding()
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.send(.pushProfileDetail("user-from-detail"))
            } label: {
                buttonLabel(
                    title: "跨模块: 查看资料",
                    subtitle: "GlobalRouter.push(.profileDetail)",
                    icon: "person.circle",
                    color: .purple
                )
            }

            Button {
                router.pop()
            } label: {
                buttonLabel(
                    title: "返回",
                    subtitle: "router.pop()",
                    icon: "chevron.left",
                    color: .gray
                )
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func buttonLabel(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body.weight(.medium))
                Text(subtitle).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 10))
    }
}
