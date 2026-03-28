import SwiftUI

/// Root tab navigation — Settings accessible from Home toolbar.
struct MainTabView: View {
    private let keychain: KeychainService
    private let client: GatewayClientProtocol
    private let cronDetailRepo: CronDetailRepository

    @State private var cronVM: CronSummaryViewModel
    @State private var memoryVM: MemoryViewModel

    init(keychain: KeychainService) {
        self.keychain = keychain
        let client = GatewayClient(keychain: keychain)
        self.client = client
        self.cronDetailRepo = RemoteCronDetailRepository(client: client)
        _cronVM = State(initialValue: CronSummaryViewModel(repository: RemoteCronRepository(client: client)))
        _memoryVM = State(initialValue: MemoryViewModel(
            repository: RemoteMemoryRepository(client: client),
            client: client
        ))
    }

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView(keychain: keychain, client: client, cronVM: cronVM, cronDetailRepository: cronDetailRepo)
            }

            Tab("Crons", systemImage: "clock.arrow.2.circlepath") {
                CronsTab(vm: cronVM, detailRepository: cronDetailRepo, client: client)
            }

            Tab("Mem & Skills", systemImage: "brain") {
                MemoryTab(vm: memoryVM)
            }

            Tab("Chat", systemImage: "bubble.left.and.bubble.right") {
                ChatTab()
            }

            Tab("More", systemImage: "ellipsis.circle") {
                MorePlaceholderTab()
            }
        }
    }
}
