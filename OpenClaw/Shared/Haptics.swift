#if canImport(UIKit)
import UIKit
#endif

/// Centralized haptic feedback triggers. No-op on macOS.
@MainActor
struct Haptics {
    static let shared = Haptics()

    func success() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    func error() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        #endif
    }

    func refreshComplete() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
}
