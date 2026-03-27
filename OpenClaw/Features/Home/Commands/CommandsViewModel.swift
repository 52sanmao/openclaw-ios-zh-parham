import Foundation
import Observation

@Observable
@MainActor
final class CommandsViewModel {
    var isRunning: [String: Bool] = [:]
    var result: CommandResult?

    private let client: GatewayClientProtocol

    init(client: GatewayClientProtocol) {
        self.client = client
    }

    func execute(_ command: QuickCommand) async {
        isRunning[command.id] = true
        do {
            let body = ExecToolRequest(args: .init(command: command.args["command"] ?? ""))
            let response: CommandResponseDTO = try await client.invoke(body)
            result = CommandResult(
                command: command,
                isSuccess: true,
                output: response.output ?? response.text ?? "Command completed."
            )
            Haptics.shared.success()
        } catch {
            result = CommandResult(
                command: command,
                isSuccess: false,
                output: error.localizedDescription
            )
            Haptics.shared.error()
        }
        isRunning[command.id] = false
    }

    func isCommandRunning(_ id: String) -> Bool {
        isRunning[id] ?? false
    }
}

struct CommandResult: Identifiable {
    let id = UUID()
    let command: QuickCommand
    let isSuccess: Bool
    let output: String
}

/// Flexible response — exec tool may return different shapes.
struct CommandResponseDTO: Decodable {
    let output: String?
    let text: String?
    let exitCode: Int?
}
