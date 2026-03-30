import SwiftUI

struct TokenSetupView: View {
    let keychain: KeychainService
    let onTokenSaved: () -> Void

    @State private var urlInput = GatewayConfig.baseURL?.absoluteString ?? ""
    @State private var tokenInput = ""
    @State private var errorMessage: String?
    @State private var isSaving = false

    private var canConnect: Bool {
        !urlInput.trimmingCharacters(in: .whitespaces).isEmpty
        && !tokenInput.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            Image("openclaw")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64)

            VStack(spacing: Spacing.xs) {
                Text("Connect to Gateway")
                    .font(AppTypography.screenTitle)
                Text("Enter your gateway URL and Bearer token to connect.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.neutral)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: Spacing.md) {
                // Gateway URL
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("GATEWAY URL")
                        .font(AppTypography.micro)
                        .foregroundStyle(AppColors.neutral)

                    TextField("https://your-gateway.example.com", text: $urlInput)
                        #if os(iOS)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        #endif
                        .autocorrectionDisabled()
                        .padding(Spacing.sm)
                        .background(AppColors.neutral.opacity(0.1), in: RoundedRectangle(cornerRadius: AppRadius.md))
                }

                // Bearer Token
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("BEARER TOKEN")
                        .font(AppTypography.micro)
                        .foregroundStyle(AppColors.neutral)

                    SecureField("Paste token here\u{2026}", text: $tokenInput)
                        #if os(iOS)
                        .textContentType(.password)
                        .textInputAutocapitalization(.never)
                        #endif
                        .autocorrectionDisabled()
                        .padding(Spacing.sm)
                        .background(AppColors.neutral.opacity(0.1), in: RoundedRectangle(cornerRadius: AppRadius.md))
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: saveConfig) {
                Group {
                    if isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Connect")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.sm + 2)
            }
            .background(AppColors.primaryAction, in: RoundedRectangle(cornerRadius: AppRadius.lg))
            .foregroundStyle(.white)
            .disabled(!canConnect || isSaving)

            Spacer()
        }
        .padding(Spacing.xl)
    }

    private func saveConfig() {
        let trimmedURL = urlInput.trimmingCharacters(in: .whitespaces)
        let trimmedToken = tokenInput.trimmingCharacters(in: .whitespaces)
        guard !trimmedURL.isEmpty, !trimmedToken.isEmpty else { return }

        isSaving = true
        errorMessage = nil

        do {
            GatewayConfig.saveBaseURL(trimmedURL)
            try keychain.saveToken(trimmedToken)
            Haptics.shared.success()
            onTokenSaved()
        } catch {
            Haptics.shared.error()
            errorMessage = error.localizedDescription
            isSaving = false
        }
    }
}
