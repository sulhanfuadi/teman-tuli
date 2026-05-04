import SwiftUI

enum TTSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28
    static let xxl: CGFloat = 36
}

enum TTCornerRadius {
    static let sm: CGFloat = 10
    static let md: CGFloat = 14
    static let lg: CGFloat = 18
    static let xl: CGFloat = 24
}

enum TTColor {
    static let brand = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.44, green: 0.67, blue: 1.0, alpha: 1.0)
            : UIColor(red: 0.0, green: 0.42, blue: 0.9, alpha: 1.0)
    })

    static let background = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? .black : UIColor.systemGroupedBackground
    })

    static let surface = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground
    })

    static let elevatedSurface = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor.tertiarySystemBackground : UIColor.secondarySystemBackground
    })

    static let captionSurface = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.08, green: 0.10, blue: 0.14, alpha: 1.0)
            : UIColor(red: 0.07, green: 0.09, blue: 0.12, alpha: 1.0)
    })

    static let success = Color(uiColor: .systemGreen)
    static let warning = Color(uiColor: .systemOrange)
    static let danger = Color(uiColor: .systemRed)
    static let subtleBorder = Color(uiColor: UIColor.separator.withAlphaComponent(0.35))
}

enum TTTypography {
    static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title = Font.system(.title2, design: .rounded, weight: .semibold)
    static let headline = Font.system(.headline, design: .rounded, weight: .semibold)
    static let body = Font.system(.body, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded)
}
