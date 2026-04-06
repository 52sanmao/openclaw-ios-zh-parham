import SwiftUI

/// Reusable model name pill (capsule badge) with provider icon.
/// Used across cron runs, investigations, trace views, token usage, admin.
///
/// When `provider` is given, it takes precedence over inferring from the model string.
/// This matters when the same model (e.g. "claude-sonnet-4-6") is served by different
/// providers (Anthropic direct vs GitHub Copilot).
struct ModelPill: View {
    let model: String
    let provider: String?

    init(model: String, provider: String? = nil) {
        self.model = model
        self.provider = provider
    }

    var body: some View {
        HStack(spacing: Spacing.xxs) {
            if let provider {
                ProviderIcon(provider: provider, size: 12)
            } else {
                ProviderIcon(model: model, size: 12)
            }
            Text(Formatters.modelShortName(model))
                .font(AppTypography.micro)
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, 2)
        .background(AppColors.pillBackground, in: Capsule())
        .foregroundStyle(AppColors.pillForeground)
    }
}
