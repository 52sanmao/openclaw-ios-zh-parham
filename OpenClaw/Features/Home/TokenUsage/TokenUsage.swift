import Foundation

enum TokenPeriod: String, CaseIterable, Identifiable {
    case today, yesterday, week

    var id: String { rawValue }

    var label: String {
        switch self {
        case .today:     "Today"
        case .yesterday: "Yesterday"
        case .week:      "7 Days"
        }
    }
}

struct TokenUsage: Sendable {
    let period: String
    let totals: Totals
    let byModel: [ModelUsage]

    struct Totals: Sendable {
        let inputTokens: Int
        let outputTokens: Int
        let cacheReadTokens: Int
        let cacheWriteTokens: Int
        let totalTokens: Int
        let requestCount: Int
        let thinkingRequests: Int
        let toolRequests: Int
        let costUsd: Double
    }

    struct ModelUsage: Sendable, Identifiable {
        var id: String { "\(model)-\(provider)" }
        let model: String
        let provider: String
        let totalTokens: Int
        let requestCount: Int
        let costUsd: Double
    }

    init(dto: TokenUsageDTO) {
        period = dto.period
        totals = Totals(
            inputTokens: dto.totals.inputTokens,
            outputTokens: dto.totals.outputTokens,
            cacheReadTokens: dto.totals.cacheReadTokens,
            cacheWriteTokens: dto.totals.cacheWriteTokens,
            totalTokens: dto.totals.totalTokens,
            requestCount: dto.totals.requestCount,
            thinkingRequests: dto.totals.thinkingRequests,
            toolRequests: dto.totals.toolRequests,
            costUsd: dto.totals.costUsd
        )
        byModel = dto.byModel
            .filter { $0.provider != "openclaw" }
            .map { ModelUsage(
                model: $0.model,
                provider: $0.provider,
                totalTokens: $0.totalTokens,
                requestCount: $0.requestCount,
                costUsd: $0.costUsd
            )}
    }
}

// MARK: - DTO

struct TokenUsageDTO: Decodable, Sendable {
    let period: String
    let totals: TotalsDTO
    let byModel: [ModelUsageDTO]

    // No CodingKeys needed — stats() decoder uses .convertFromSnakeCase

    struct TotalsDTO: Decodable, Sendable {
        let inputTokens: Int
        let outputTokens: Int
        let cacheReadTokens: Int
        let cacheWriteTokens: Int
        let totalTokens: Int
        let requestCount: Int
        let thinkingRequests: Int
        let toolRequests: Int
        let costUsd: Double
    }

    struct ModelUsageDTO: Decodable, Sendable {
        let model: String
        let provider: String
        let totalTokens: Int
        let requestCount: Int
        let costUsd: Double
    }
}
