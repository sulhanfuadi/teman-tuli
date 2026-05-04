import SwiftUI

struct BrandMarkView: View {
    var size: CGFloat = 36

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [TTColor.brand, TTColor.brandDeep],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                .strokeBorder(.white.opacity(0.35), lineWidth: size * 0.04)
                .padding(size * 0.1)

            VStack(alignment: .leading, spacing: size * 0.08) {
                Capsule()
                    .fill(.white)
                    .frame(width: size * 0.48, height: size * 0.1)
                Capsule()
                    .fill(.white.opacity(0.92))
                    .frame(width: size * 0.62, height: size * 0.1)
                Capsule()
                    .fill(.white.opacity(0.84))
                    .frame(width: size * 0.36, height: size * 0.1)
            }
            .offset(x: size * 0.02)
        }
        .frame(width: size, height: size)
        .shadow(color: TTColor.brand.opacity(0.22), radius: size * 0.16, x: 0, y: size * 0.10)
    }
}

struct BrandWordmarkView: View {
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: TTSpacing.sm) {
            BrandMarkView(size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.tr("app.title"))
                    .font(.system(.title3, design: .rounded, weight: .bold))
                if let subtitle {
                    Text(subtitle)
                        .font(TTTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }
}
