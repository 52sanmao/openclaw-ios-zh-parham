import SwiftUI

struct SessionsView: View {
    @State var vm: SessionsViewModel
    let repository: SessionRepository
    @State private var selectedTab: SessionTab = .chat

    enum SessionTab: String, CaseIterable {
        case chat = "Chat History"
        case subagents = "Subagents"
    }

    var body: some View {
        NavigationStack {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                ForEach(SessionTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)

            switch selectedTab {
            case .chat:
                chatSection
            case .subagents:
                subagentsSection
            }
        }
        .navigationTitle("Sessions")
        .navigationBarTitleDisplayMode(.large)
        }
        .task { await vm.load() }
    }

    // MARK: - Chat History

    @ViewBuilder
    private var chatSection: some View {
        if vm.isLoading && vm.mainSession == nil {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let main = vm.mainSession {
            List {
                Section {
                    NavigationLink {
                        SessionTraceView(
                            sessionKey: main.key,
                            title: "Main Session",
                            subtitle: main.startedAtFormatted,
                            newestFirst: true,
                            repository: repository
                        )
                    } label: {
                        MainSessionRow(session: main)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .refreshable {
                await vm.load()
                Haptics.shared.refreshComplete()
            }
        } else if let err = vm.error {
            List { CardErrorView(error: err, minHeight: 60) }
                .listStyle(.insetGrouped)
        } else {
            ContentUnavailableView(
                "No Session",
                systemImage: "bubble.left.and.bubble.right",
                description: Text("No active chat session found.")
            )
        }
    }

    // MARK: - Subagents

    @ViewBuilder
    private var subagentsSection: some View {
        if vm.isLoading && vm.subagents.isEmpty {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if !vm.subagents.isEmpty {
            List(vm.subagents) { session in
                NavigationLink {
                    SessionTraceView(
                        sessionKey: session.key,
                        title: session.displayName,
                        subtitle: session.updatedAtFormatted,
                        repository: repository
                    )
                } label: {
                    SubagentRow(session: session)
                }
            }
            .listStyle(.insetGrouped)
            .refreshable {
                await vm.load()
                Haptics.shared.refreshComplete()
            }
        } else if let err = vm.error {
            List { CardErrorView(error: err, minHeight: 60) }
                .listStyle(.insetGrouped)
        } else {
            ContentUnavailableView(
                "No Subagents",
                systemImage: "point.3.connected.trianglepath.dotted",
                description: Text("No subagent sessions found.")
            )
        }
    }
}

// MARK: - Rows

private struct MainSessionRow: View {
    let session: SessionEntry

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(AppTypography.statusIcon)
                    .foregroundStyle(session.status == .running ? AppColors.success : AppColors.neutral)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Main Session")
                        .font(AppTypography.body)
                        .fontWeight(.semibold)
                    Text(session.status == .running ? "Running" : "Idle")
                        .font(AppTypography.micro)
                        .foregroundStyle(session.status == .running ? AppColors.success : AppColors.neutral)
                }
                Spacer()
            }

            HStack(spacing: Spacing.sm) {
                if let model = session.model {
                    ModelPill(model: model)
                }
                Label(Formatters.tokens(session.totalTokens), systemImage: "number.circle")
                    .font(AppTypography.micro)
                    .foregroundStyle(AppColors.metricPrimary)
                if session.costUsd > 0 {
                    Text(Formatters.cost(session.costUsd))
                        .font(AppTypography.micro)
                        .foregroundStyle(AppColors.metricWarm)
                }
                Spacer()
            }

            HStack(spacing: Spacing.sm) {
                Label("\(session.childSessionCount) subagents", systemImage: "point.3.connected.trianglepath.dotted")
                    .font(AppTypography.micro)
                    .foregroundStyle(AppColors.neutral)
                Label(session.updatedAtFormatted, systemImage: "clock")
                    .font(AppTypography.micro)
                    .foregroundStyle(AppColors.neutral)
            }
        }
        .padding(.vertical, Spacing.xxs)
        .accessibilityElement(children: .combine)
    }
}

private struct SubagentRow: View {
    let session: SessionEntry

    var body: some View {
        HStack(spacing: Spacing.xs) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(session.displayName)
                    .font(AppTypography.body)
                    .lineLimit(1)

                HStack(spacing: Spacing.sm) {
                    if let model = session.model {
                        ModelPill(model: model)
                    }
                    Label(Formatters.tokens(session.totalTokens), systemImage: "number.circle")
                        .font(AppTypography.micro)
                        .foregroundStyle(AppColors.metricPrimary)
                    Spacer()
                    Text(session.updatedAtFormatted)
                        .font(AppTypography.micro)
                        .foregroundStyle(AppColors.neutral)
                }
            }
        }
        .padding(.vertical, Spacing.xxs)
        .accessibilityElement(children: .combine)
    }
}
