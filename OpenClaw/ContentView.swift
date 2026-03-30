import SwiftUI

/// Root view: shows TokenSetupView until both gateway URL and token are configured,
/// then transitions to MainTabView with a smooth animation.
struct ContentView: View {
    private let keychain: KeychainService
    @State private var isAuthenticated: Bool

    init() {
        let keychain = KeychainService()
        self.keychain = keychain
        _isAuthenticated = State(initialValue: keychain.hasToken && GatewayConfig.isConfigured)
    }

    var body: some View {
        Group {
            if isAuthenticated {
                MainTabView(keychain: keychain)
            } else {
                TokenSetupView(keychain: keychain) {
                    withAnimation(.easeInOut) {
                        isAuthenticated = true
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
