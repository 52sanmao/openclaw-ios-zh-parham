import Foundation
import Observation

@Observable
@MainActor
final class AdminViewModel {
    var modelsConfig: ModelsConfig?
    var agents: [AgentInfo] = []
    var channelsStatus: ChannelsStatus?
    var isLoading = false
    var error: Error?

    private let client: GatewayClientProtocol

    init(client: GatewayClientProtocol) {
        self.client = client
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        error = nil

        await loadModels()
        await loadAgents()
        await loadChannels()
    }

    private func loadModels() async {
        do {
            let response: StatsExecResponse = try await client.statsPost(
                "stats/exec", body: StatsExecRequest(command: "models-status")
            )
            if let data = response.stdout?.data(using: .utf8) {
                let dto = try JSONDecoder().decode(ModelsStatusDTO.self, from: data)
                modelsConfig = ModelsConfig(dto: dto)
            }
        } catch {
            self.error = error
        }
    }

    private func loadAgents() async {
        do {
            let response: StatsExecResponse = try await client.statsPost(
                "stats/exec", body: StatsExecRequest(command: "agents-list")
            )
            if let data = response.stdout?.data(using: .utf8) {
                let dtos = try JSONDecoder().decode([AgentDTO].self, from: data)
                agents = dtos.map(AgentInfo.init)
            }
        } catch {
            self.error = error
        }
    }

    private func loadChannels() async {
        do {
            let response: StatsExecResponse = try await client.statsPost(
                "stats/exec", body: StatsExecRequest(command: "channels-list")
            )
            if let data = response.stdout?.data(using: .utf8) {
                let dto = try JSONDecoder().decode(ChannelsListDTO.self, from: data)
                channelsStatus = ChannelsStatus(dto: dto)
            }
        } catch {
            self.error = error
        }
    }
}
