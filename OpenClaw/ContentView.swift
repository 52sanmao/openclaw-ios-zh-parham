import SwiftUI

/// Root view: shows setup when no accounts exist, main app when configured.
/// Account switching triggers a full app rebuild via `id:`.
struct ContentView: View {
    @State private var accountStore = AccountStore()

    var body: some View {
        Group {
            if accountStore.isConfigured {
                MainTabView(accountStore: accountStore)
                    .id(accountStore.activeAccountId)
            } else {
                AddAccountView(accountStore: accountStore)
            }
        }
    }
}

#Preview {
    ContentView()
}
