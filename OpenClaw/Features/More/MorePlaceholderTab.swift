import SwiftUI

struct MoreTab: View {
    let client: GatewayClientProtocol

    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("More", systemImage: "ellipsis.circle")
            } description: {
                Text("Additional features coming soon.")
                    .font(AppTypography.body)
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
