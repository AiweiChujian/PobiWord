import SwiftUI
import AppUI

struct ProfileEditView: ReduxView {
    @StateObject var viewModel = ProfileEditViewModel()
    @EnvironmentObject private var router: Router

    var reduxBody: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "pencil.and.list.clipboard")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("Edit Profile")
                .font(.title.bold())

            Text("来自 AppProfile 模块的编辑页\n通过 Router (ExportableRouter) 导出")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 12) {
                Button { router.pop() } label: {
                    actionLabel(title: "保存并返回", subtitle: "router.pop()", icon: "checkmark.circle", color: .green)
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
