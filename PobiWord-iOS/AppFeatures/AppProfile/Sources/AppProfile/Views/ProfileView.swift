import SwiftUI
import AppUI

struct ProfileView: ReduxView {
    @StateObject var viewModel = ProfileViewModel()

    var reduxBody: some View {
        ScrollView {
            VStack(spacing: 16) {
                profileHeader

                Divider().padding(.horizontal)

                menuSection

                Divider().padding(.horizontal)

                crossModuleSection
            }
            .padding()
        }
        .navigationBarHidden(true)
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.purple)

            Text("Demo User")
                .font(.title2.bold())

            Text("Profile Feature Module")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical)
    }

    private var menuSection: some View {
        VStack(spacing: 12) {
            menuButton(
                title: "查看资料详情",
                subtitle: "Push ProfileDetailView (模块内导航)",
                icon: "person.text.rectangle",
                color: .purple
            ) {
                viewModel.send(.pushDetail("current-user"))
            }

            menuButton(
                title: "编辑资料",
                subtitle: "Push ProfileEditView (模块内导航)",
                icon: "pencil.circle",
                color: .orange
            ) {
                viewModel.send(.pushEdit)
            }
        }
    }

    private var crossModuleSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("跨模块导航")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            menuButton(
                title: "查看推荐内容",
                subtitle: "Push HomeDetailView (跨模块 → AppHome)",
                icon: "doc.text",
                color: .blue
            ) {
                viewModel.send(.pushHomeDetail("recommended-item"))
            }
        }
    }

    @ViewBuilder
    private func menuButton(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.body.weight(.medium))
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
