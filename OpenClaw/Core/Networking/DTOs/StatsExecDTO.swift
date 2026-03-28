import Foundation

struct StatsExecRequest: Encodable, Sendable {
    let command: String
    let args: String?

    init(command: String, args: String? = nil) {
        self.command = command
        self.args = args
    }
}

struct StatsExecResponse: Decodable, Sendable {
    let command: String?
    let exitCode: Int?
    let stdout: String?
    let stderr: String?
    let durationMs: Int?
}
