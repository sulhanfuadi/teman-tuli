import SwiftUI

struct SectionCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(TTSpacing.md)
            .background(TTColor.surface)
            .overlay(
                RoundedRectangle(cornerRadius: TTCornerRadius.lg)
                    .stroke(TTColor.subtleBorder, lineWidth: 0.8)
            )
            .clipShape(RoundedRectangle(cornerRadius: TTCornerRadius.lg, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
    }
}

enum StatusCardStyle {
    case info
    case success
    case warning
    case error

    var color: Color {
        switch self {
        case .info: return TTColor.brand
        case .success: return TTColor.success
        case .warning: return TTColor.warning
        case .error: return TTColor.danger
        }
    }

    var icon: String {
        switch self {
        case .info: return "info.circle"
        case .success: return "checkmark.circle"
        case .warning: return "exclamationmark.triangle"
        case .error: return "xmark.octagon"
        }
    }
}

struct StatusCard: View {
    let style: StatusCardStyle
    let message: String
    var detail: String?

    var body: some View {
        VStack(alignment: .leading, spacing: TTSpacing.xs) {
            Label(message, systemImage: style.icon)
                .font(TTTypography.body)
                .foregroundStyle(style.color)
            if let detail {
                Text(detail)
                    .font(TTTypography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(TTSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(style.color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: TTCornerRadius.md, style: .continuous))
    }
}

struct InlineNotice: View {
    let message: String
    var style: StatusCardStyle = .info

    var body: some View {
        HStack(spacing: TTSpacing.xs) {
            Image(systemName: style.icon)
                .foregroundStyle(style.color)
            Text(message)
                .font(TTTypography.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(TTSpacing.sm)
        .background(TTColor.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: TTCornerRadius.md, style: .continuous))
    }
}

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(spacing: TTSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(TTColor.brand)
            Text(title)
                .font(TTTypography.title)
            Text(subtitle)
                .font(TTTypography.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(TTSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(TTColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: TTCornerRadius.xl, style: .continuous))
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TTTypography.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, TTSpacing.sm)
            .background(TTColor.brand.opacity(configuration.isPressed ? 0.82 : 1.0))
            .clipShape(RoundedRectangle(cornerRadius: TTCornerRadius.md, style: .continuous))
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TTTypography.headline)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, TTSpacing.sm)
            .background(TTColor.elevatedSurface.opacity(configuration.isPressed ? 0.75 : 1.0))
            .overlay(
                RoundedRectangle(cornerRadius: TTCornerRadius.md)
                    .stroke(TTColor.subtleBorder, lineWidth: 0.8)
            )
            .clipShape(RoundedRectangle(cornerRadius: TTCornerRadius.md, style: .continuous))
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}
