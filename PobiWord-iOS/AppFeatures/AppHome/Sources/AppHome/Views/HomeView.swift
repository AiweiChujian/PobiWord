import SwiftUI
import AppUI

struct HomeView: ReduxView {
    @StateObject var viewModel = HomeViewModel()

    var reduxBody: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerSection

                ForEach(1...5, id: \.self) { index in
                    itemButton(index: index)
                }

                Divider().padding(.horizontal)

                crossModuleSection
            }
            .padding()
        }
        .navigationBarHidden(true)
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Home")
                    .font(.largeTitle.bold())
                Text("Feature Module")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "house.fill")
                .font(.title)
                .foregroundStyle(.blue)
        }
    }

    private func itemButton(index: Int) -> some View {
        Button {
            viewModel.send(.pushDetail("Item-\(index)"))
        } label: {
            HStack {
                Image(systemName: "doc.text")
                    .frame(width: 32)
                VStack(alignment: .leading) {
                    Text("Item \(index)")
                        .font(.body.weight(.medium))
                    Text("Push HomeDetailView (模块内导航)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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

    private var crossModuleSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("跨模块导航")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Button {
                viewModel.send(.pushProfileDetail("user-from-home"))
            } label: {
                HStack {
                    Image(systemName: "person.circle")
                        .frame(width: 32)
                    VStack(alignment: .leading) {
                        Text("查看用户资料")
                            .font(.body.weight(.medium))
                        Text("Push ProfileDetailView (跨模块 → AppProfile)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "arrow.right.circle")
                        .foregroundStyle(.purple)
                }
                .padding(12)
                .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
    }
}
