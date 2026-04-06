import SwiftUI

/// Error label that distinguishes connection-lost (warning) from real errors (danger).
/// Use this for agent call errors where backgrounding the app causes a false failure.
struct ErrorLabel: View {
    let error: Error

    private var isConnectionLost: Bool {
        if case .connectionLost = error as? GatewayError { return true }
        return false
    }

    var body: some View {
        Label(
            error.localizedDescription,
            systemImage: isConnectionLost ? "wifi.exclamationmark" : "xmark.circle.fill"
        )
        .font(AppTypography.caption)
        .foregroundStyle(isConnectionLost ? AppColors.warning : AppColors.danger)
    }
}
