import SwiftUI

struct MoreTab: View {
    let client: GatewayClientProtocol

    var body: some View {
        NavigationStack {
            List {
                // Future items go here
            }
            .listStyle(.insetGrouped)
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .overlay {
                if true {
                    ContentUnavailableView {
                        Label("More", systemImage: "ellipsis.circle")
                    } description: {
                        Text("Additional features coming soon.")
                            .font(AppTypography.body)
                    }
                }
            }
        }
    }
}
