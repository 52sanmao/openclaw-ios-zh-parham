import Foundation

struct ChatMessage: Identifiable, Sendable {
    let id: UUID
    let role: Role
    var content: String
    var isStreaming: Bool
    let timestamp: Date

    enum Role: Sendable {
        case user
        case assistant
    }

    init(role: Role, content: String, isStreaming: Bool = false, timestamp: Date = Date()) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.isStreaming = isStreaming
        self.timestamp = timestamp
    }
}
