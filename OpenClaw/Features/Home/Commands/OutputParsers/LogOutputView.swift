import SwiftUI

/// Parsed log viewer with level filtering and structured display.
struct LogOutputView: View {
    let output: String
    @State private var hiddenLevels: Set<LogEntry.Level> = [.debug]

    private var parsed: (entries: [LogEntry], logFile: String?) {
        LogEntry.parse(output)
    }

    private var filteredEntries: [LogEntry] {
        parsed.entries.filter { !hiddenLevels.contains($0.level) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Log file path
            if let path = parsed.logFile {
                Text(path)
                    .font(AppTypography.captionMono)
                    .foregroundStyle(AppColors.neutral)
                    .lineLimit(1)
            }

            // Level filter chips
            HStack(spacing: Spacing.xs) {
                ForEach(LogEntry.Level.allCases, id: \.self) { level in
                    let isVisible = !hiddenLevels.contains(level)
                    let count = parsed.entries.filter { $0.level == level }.count
                    Button {
                        withAnimation(.snappy(duration: 0.2)) {
                            if isVisible { hiddenLevels.insert(level) }
                            else { hiddenLevels.remove(level) }
                        }
                    } label: {
                        HStack(spacing: Spacing.xxs) {
                            Circle()
                                .fill(isVisible ? level.color : AppColors.neutral.opacity(0.3))
                                .frame(width: 6, height: 6)
                            Text("\(level.rawValue) (\(count))")
                                .font(AppTypography.micro)
                        }
                        .foregroundStyle(isVisible ? level.color : AppColors.neutral.opacity(0.5))
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, Spacing.xxs)
                        .background(
                            isVisible ? AppColors.tintedBackground(level.color) : AppColors.neutral.opacity(0.04),
                            in: Capsule()
                        )
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }

            // Log entries
            if filteredEntries.isEmpty {
                Text("No entries match the current filter.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.neutral)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
            } else {
                ForEach(filteredEntries) { entry in
                    LogEntryRow(entry: entry)
                }
            }
        }
    }
}

// MARK: - Log Entry Row

private struct LogEntryRow: View {
    let entry: LogEntry

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.xs) {
            // Time
            Text(entry.time)
                .font(AppTypography.nano)
                .foregroundStyle(AppColors.neutral)
                .frame(width: 50, alignment: .leading)

            // Level dot
            Image(systemName: entry.level.icon)
                .font(.system(size: 8))
                .foregroundStyle(entry.level.color)
                .frame(width: 12)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: Spacing.xxs) {
                    Text(entry.module)
                        .font(AppTypography.nano)
                        .foregroundStyle(entry.level.color)

                    if let ms = entry.duration {
                        Text("\(ms)ms")
                            .font(AppTypography.nano)
                            .foregroundStyle(ms > 3000 ? AppColors.warning : AppColors.neutral)
                    }
                }

                Text(entry.message)
                    .font(AppTypography.micro)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }
}
