import SwiftUI

/// Read-only monospace viewer for non-markdown files (scripts, JSON, config).
struct ReadOnlyFileView: View {
    var vm: MemoryViewModel
    let entry: SkillFileEntry

    var body: some View {
        Group {
            if vm.isLoadingContent || (vm.fileContent == nil && vm.contentError == nil) {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = vm.contentError {
                ContentUnavailableView(
                    "Cannot Load",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                )
            } else if let content = vm.fileContent {
                ScrollView([.horizontal, .vertical]) {
                    Text(content.text)
                        .font(AppTypography.captionMono)
                        .textSelection(.enabled)
                        .padding(Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(AppColors.neutral.opacity(0.04))
            }
        }
        .navigationTitle(entry.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let content = vm.fileContent {
                ToolbarItem(placement: .cancellationAction) {
                    CopyToolbarButton(text: content.text)
                }
            }
        }
        .task { await vm.loadSkillFileContent(entry) }
    }
}
