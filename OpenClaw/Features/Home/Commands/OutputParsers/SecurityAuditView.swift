import os
import SwiftUI

/// Parsed security audit viewer with severity-coded findings.
struct SecurityAuditView: View {
    let output: String

    private var audit: SecurityAudit { SecurityAudit.parse(output) }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Summary bar
            HStack(spacing: Spacing.sm) {
                summaryBadge(audit.criticalCount, "critical", AppColors.danger)
                summaryBadge(audit.warnCount, "warn", AppColors.warning)
                summaryBadge(audit.infoCount, "info", AppColors.primaryAction)
                Spacer()
            }

            if let deeper = audit.deeperCommand {
                Text(deeper)
                    .font(AppTypography.captionMono)
                    .foregroundStyle(AppColors.neutral)
            }

            // Findings
            if audit.findings.isEmpty {
                // Debug: show raw output if parsing failed
                Text(output)
                    .font(AppTypography.captionMono)
                    .foregroundStyle(AppColors.neutral)
                    .textSelection(.enabled)
                    .padding(Spacing.sm)
                    .background(AppColors.neutral.opacity(0.08), in: RoundedRectangle(cornerRadius: AppRadius.sm))
            } else {
                ForEach(audit.findings) { finding in
                    FindingRow(finding: finding)
                }
            }
        }
    }

    private func summaryBadge(_ count: Int, _ label: String, _ color: Color) -> some View {
        HStack(spacing: Spacing.xxs) {
            Text("\(count)")
                .font(AppTypography.captionBold)
                .foregroundStyle(count > 0 ? color : AppColors.neutral)
            Text(label)
                .font(AppTypography.micro)
                .foregroundStyle(AppColors.neutral)
        }
    }
}

// MARK: - Finding Row

private struct FindingRow: View {
    let finding: SecurityFinding
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Button {
                withAnimation(.snappy(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack(alignment: .top, spacing: Spacing.xs) {
                    Image(systemName: finding.level.icon)
                        .font(AppTypography.caption)
                        .foregroundStyle(finding.level.color)
                        .frame(width: 16)

                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(finding.title)
                            .font(AppTypography.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                        Text(finding.id)
                            .font(AppTypography.nano)
                            .foregroundStyle(AppColors.neutral)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(AppTypography.micro)
                        .foregroundStyle(AppColors.neutral)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(finding.description)
                        .font(AppTypography.micro)
                        .foregroundStyle(AppColors.neutral)

                    if let fix = finding.fix {
                        HStack(alignment: .top, spacing: Spacing.xs) {
                            Image(systemName: "wrench.and.screwdriver")
                                .font(AppTypography.micro)
                                .foregroundStyle(AppColors.success)
                            Text(fix)
                                .font(AppTypography.micro)
                                .foregroundStyle(.primary)
                        }
                        .padding(Spacing.xs)
                        .background(AppColors.tintedBackground(AppColors.success, opacity: 0.06), in: RoundedRectangle(cornerRadius: AppRadius.sm))
                    }
                }
                .padding(.leading, 24)
            }
        }
        .padding(.vertical, Spacing.xxs)
    }
}

// MARK: - Models + Parser

struct SecurityAudit {
    let criticalCount: Int
    let warnCount: Int
    let infoCount: Int
    let deeperCommand: String?
    let findings: [SecurityFinding]

    static func parse(_ output: String) -> SecurityAudit {
        let logger = os.Logger(subsystem: "co.uk.appwebdev.openclaw", category: "SecurityParser")
        let lines = output.components(separatedBy: "\n")
        logger.debug("SecurityAudit: \(lines.count) lines to parse")
        for (i, line) in lines.prefix(10).enumerated() {
            logger.debug("  line[\(i)]: [\(line)]")
        }
        var criticalCount = 0, warnCount = 0, infoCount = 0
        var deeperCommand: String?
        var findings: [SecurityFinding] = []
        var currentLevel: SecurityFinding.Level?
        var currentId: String?
        var currentTitle: String?
        var descLines: [String] = []
        var fixLines: [String] = []
        var inFix = false

        func flush() {
            guard let level = currentLevel, let id = currentId, let title = currentTitle else { return }
            findings.append(SecurityFinding(
                id: id, level: level, title: title,
                description: descLines.joined(separator: " ").trimmingCharacters(in: .whitespaces),
                fix: fixLines.isEmpty ? nil : fixLines.joined(separator: " ").trimmingCharacters(in: .whitespaces)
            ))
            currentId = nil; currentTitle = nil; descLines = []; fixLines = []; inFix = false
        }

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }

            // Summary line
            if trimmed.lowercased().hasPrefix("summary:") || trimmed.contains("critical") && trimmed.contains("warn") && trimmed.contains("info") && trimmed.contains("·") {
                let parts = trimmed.components(separatedBy: "·").map { $0.trimmingCharacters(in: .whitespaces) }
                for part in parts {
                    let tokens = part.split(separator: " ")
                    if let n = tokens.first.flatMap({ Int($0) }) {
                        let label = tokens.last?.lowercased() ?? ""
                        if label.contains("critical") { criticalCount = n }
                        else if label.contains("warn") { warnCount = n }
                        else if label.contains("info") { infoCount = n }
                    }
                }
                continue
            }

            // Deeper command hint
            if trimmed.hasPrefix("Run deeper:") {
                deeperCommand = String(trimmed.dropFirst(11)).trimmingCharacters(in: .whitespaces)
                continue
            }

            // Level headers
            if trimmed == "CRITICAL" || trimmed == "WARN" || trimmed == "INFO" {
                flush()
                currentLevel = SecurityFinding.Level(rawValue: trimmed.lowercased())
                logger.debug("  → level header: \(trimmed)")
                continue
            }

            // Issue ID + title on same line: "gateway.foo.bar Some title text"
            // ID is the first word containing dots, rest is title
            if currentLevel != nil && trimmed.first?.isLetter == true {
                let firstSpace = trimmed.firstIndex(of: " ")
                let firstWord = firstSpace.map { String(trimmed[trimmed.startIndex..<$0]) } ?? trimmed
                if firstWord.contains(".") && firstWord.count > 3 {
                    flush()
                    currentId = firstWord
                    currentTitle = firstSpace.map { String(trimmed[trimmed.index(after: $0)...]).trimmingCharacters(in: .whitespaces) }
                    logger.debug("  → issue: \(firstWord)")
                    continue
                }
            }

            // Fix line (may have leading whitespace)
            if trimmed.hasPrefix("Fix:") {
                inFix = true
                fixLines.append(String(trimmed.dropFirst(4)).trimmingCharacters(in: .whitespaces))
                continue
            }

            // Accumulate description or fix (indented lines)
            if inFix {
                fixLines.append(trimmed)
            } else if currentTitle != nil {
                descLines.append(trimmed)
            }
        }
        flush()

        return SecurityAudit(criticalCount: criticalCount, warnCount: warnCount, infoCount: infoCount, deeperCommand: deeperCommand, findings: findings)
    }
}

struct SecurityFinding: Identifiable {
    let id: String
    let level: Level
    let title: String
    let description: String
    let fix: String?

    enum Level: String {
        case critical, warn, info

        var color: Color {
            switch self {
            case .critical: AppColors.danger
            case .warn:     AppColors.warning
            case .info:     AppColors.primaryAction
            }
        }

        var icon: String {
            switch self {
            case .critical: "xmark.shield.fill"
            case .warn:     "exclamationmark.shield.fill"
            case .info:     "info.circle.fill"
            }
        }
    }
}
