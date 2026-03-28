import SwiftUI

struct MorePlaceholderTab: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("More", systemImage: "ellipsis.circle")
                    .font(AppTypography.screenTitle)
            } description: {
                Text("Additional features coming soon.")
                    .font(AppTypography.body)
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
