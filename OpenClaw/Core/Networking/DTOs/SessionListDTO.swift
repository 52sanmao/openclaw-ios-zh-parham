import Foundation

struct SessionListResponseDTO: Decodable, Sendable {
    let count: Int
    let sessions: [SessionListDTO]
}

struct SessionListDTO: Decodable, Sendable {
    let key: String
    let displayName: String?
    let label: String?
    let model: String?
    let status: String?
    let updatedAt: Int?
    let startedAt: Int?
    let totalTokens: Int?
    let estimatedCostUsd: Double?
    let contextTokens: Int?
    let sessionId: String?
    let channel: String?
    let childSessions: [String]?
}
