import MarkdownUI
import SwiftUI

struct CommandsCard: View {
    @State var vm: CommandsViewModel
    @State private var isExpanded = false
    @State private var commandToConfirm: QuickCommand?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.xs), count: 3)

    private var visibleCommands: [QuickCommand] {
        isExpanded ? QuickCommand.all : Array(QuickCommand.all.prefix(QuickCommand.visibleCount))
    }

    var body: some View {
        CardContainer(
            title: "Commands",
            systemImage: "terminal.fill",
            isStale: false,
            isLoading: false
        ) {
            VStack(spacing: Spacing.sm) {
                LazyVGrid(columns: columns, spacing: Spacing.xs) {
                    ForEach(visibleCommands) { cmd in
                        CommandButton(
                            command: cmd,
                            isRunning: vm.isCommandRunning(cmd.id)
                        ) {
                            commandToConfirm = cmd
                        }
                    }
                }

                // Show More / Show Less
                if QuickCommand.all.count > QuickCommand.visibleCount {
                    Button {
                        withAnimation(.snappy(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        HStack(spacing: Spacing.xxs) {
                            Text(isExpanded ? "Show Less" : "Show More")
                                .font(AppTypography.caption)
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(AppTypography.micro)
                        }
                        .foregroundStyle(AppColors.primaryAction)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.xxs)
                    }
                }
            }
        }
        .alert("Run Command?", isPresented: Binding(
            get: { commandToConfirm != nil },
            set: { if !$0 { commandToConfirm = nil } }
        )) {
            Button("Run", role: .destructive) {
                guard let cmd = commandToConfirm else { return }
                Task { await vm.execute(cmd) }
            }
            Button("Cancel", role: .cancel) { commandToConfirm = nil }
        } message: {
            if let cmd = commandToConfirm {
                Text(cmd.confirmMessage)
            }
        }
        .sheet(item: $vm.result) { result in
            CommandResultSheet(result: result)
        }
    }
}

// MARK: - Result Modal

private struct CommandResultSheet: View {
    let result: CommandResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    // Status header
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: result.isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(result.isSuccess ? AppColors.success : AppColors.danger)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(result.command.name)
                                .font(AppTypography.body)
                                .fontWeight(.semibold)
                            Text(result.isSuccess ? "Completed" : "Failed")
                                .font(AppTypography.micro)
                                .foregroundStyle(result.isSuccess ? AppColors.success : AppColors.danger)
                        }
                    }

                    Divider()

                    // Output
                    Markdown(result.output)
                        .markdownTheme(.openClaw)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(Spacing.md)
            }
            .navigationTitle("Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
