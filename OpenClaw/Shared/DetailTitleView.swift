import SwiftUI

/// Shared detail page title with subtitle chip/text underneath.
/// Used as a custom navigation title replacement for detail views.
struct DetailTitleView: View {
    let title: String
    let subtitle: AnyView

    init(title: String, @ViewBuilder subtitle: () -> some View) {
        self.title = title
        self.subtitle = AnyView(subtitle())
    }

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(AppTypography.body)
                .fontWeight(.semibold)
                .lineLimit(1)
            subtitle
        }
    }
}
