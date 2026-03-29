import Foundation
import SwiftUI

struct LogEntry: Identifiable, Sendable {
    let id: Int
    let time: String
    let level: Level
    let module: String
    let message: String
    let duration: Int?

    enum Level: String, CaseIterable, Sendable {
        case debug, info, warn, error

        var color: Color {
            switch self {
            case .debug: AppColors.neutral
            case .info:  AppColors.primaryAction
            case .warn:  AppColors.warning
            case .error: AppColors.danger
            }
        }

        var icon: String {
            switch self {
            case .debug: "ant"
            case .info:  "info.circle"
            case .warn:  "exclamationmark.triangle"
            case .error: "xmark.circle"
            }
        }
    }

    /// Parse raw log output into structured entries.
    static func parse(_ output: String) -> (entries: [LogEntry], logFile: String?) {
        let lines = output.components(separatedBy: "\n")
        var entries: [LogEntry] = []
        var logFile: String?

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Log file path header
            if trimmed.hasPrefix("Log file:") {
                logFile = String(trimmed.dropFirst(9)).trimmingCharacters(in: .whitespaces)
                continue
            }

            // Skip empty lines and footer
            if trimmed.isEmpty || trimmed.hasPrefix("---") { continue }

            // Parse: 2026-03-29T18:24:35.022+00:00 info gateway/ws {...} message
            guard let entry = parseLine(trimmed, index: index) else { continue }
            entries.append(entry)
        }

        return (entries, logFile)
    }

    private static func parseLine(_ line: String, index: Int) -> LogEntry? {
        // Match ISO timestamp at start
        guard line.count > 30,
              line[line.index(line.startIndex, offsetBy: 4)] == "-" else { return nil }

        let parts = line.split(separator: " ", maxSplits: 3)
        guard parts.count >= 4 else { return nil }

        let timestamp = String(parts[0])
        let levelStr = String(parts[1])
        let module = String(parts[2])
        let rest = String(parts[3])

        guard let level = Level(rawValue: levelStr) else { return nil }

        // Extract time (HH:mm:ss)
        let time: String
        if let tIndex = timestamp.firstIndex(of: "T") {
            let afterT = timestamp[timestamp.index(after: tIndex)...]
            time = String(afterT.prefix(8))
        } else {
            time = timestamp
        }

        // Strip JSON metadata blocks from message
        let message = stripJsonMetadata(rest)

        // Extract duration (e.g. "3346ms")
        let duration = extractDuration(rest)

        return LogEntry(id: index, time: time, level: level, module: module, message: message, duration: duration)
    }

    private static func stripJsonMetadata(_ text: String) -> String {
        var result = text
        // Remove {...} blocks at the start
        while result.hasPrefix("{") {
            if let end = result.firstIndex(of: "}") {
                result = String(result[result.index(after: end)...]).trimmingCharacters(in: .whitespaces)
            } else {
                break
            }
        }
        return result.trimmingCharacters(in: .whitespaces)
    }

    private static func extractDuration(_ text: String) -> Int? {
        let pattern = #"(\d+)ms"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text) else { return nil }
        return Int(text[range])
    }
}
