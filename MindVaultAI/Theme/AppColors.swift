import SwiftUI

enum AppColors {
    static let background = Color("Background")
    static let cardBackground = Color("CardBackground")
    static let cardBorder = Color("CardBorder")
    static let surfaceSecondary = Color("SurfaceSecondary")

    static let accentTeal = Color("AccentTeal")
    static let accentPurple = Color("AccentPurple")

    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")

    static let micGradient = LinearGradient(
        colors: [Color("AccentPurple"), Color("AccentTeal")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let topicAccentColors: [Color] = [
        .teal, .purple, .blue, .orange, .pink, .green, .indigo, .mint
    ]
}
