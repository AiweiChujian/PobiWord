import SwiftUI
import AppUI

struct ProfileDetailView: ReduxView {
    @StateObject var viewModel = ProfileDetailViewModel()
    @EnvironmentObject private var router: Router
    let userId: String

    var reduxBody: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.crop.rectangle.stack")
                .font(.system(size: 60))
                .foregroundStyle(.purple)

            Text("Profile Detail")
                .font(.title.bold())

            Text("User: \(userId)")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("来自 AppProfile 模块的详情页\n通过 Router (ExportableRouter) 导出")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 12) {
                Button {
                    viewModel.send(.pushEdit)
                } label: {
                    actionLabel(title: "编辑资料", subtitle: "模块内 push", icon: "pencil.circle", color: .orange)
                }

                Button {
                    viewModel.send(.pushHomeDetail("from-profile"))
                } label: {
                    actionLabel(title: "跨模块: 查看内容", subtitle: "GlobalRouter.push(.homeDetail)", icon: "doc.text", color: .blue)
                }

                Button { router.pop() } label: {
                    actionLabel(title: "返回", subtitle: "router.pop()", icon: "chevron.left", color: .gray)
                }

                Button { router.popToRoot() } label: {
                    actionLabel(title: "回到 Root", subtitle: "router.popToRoot()", icon: "arrow.uturn.left", color: .red)
                }
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding()
    }

    @ViewBuilder
    private func actionLabel(title: String, subtitle: String, icon: String, color: Color) -> some View {
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
