import SwiftUI

enum AppTheme {

    enum CornerRadius {
        static let card: CGFloat = 16
        static let searchBar: CGFloat = 12
        static let entryBubble: CGFloat = 12
        static let button: CGFloat = 24
    }

    enum Spacing {
        static let sectionGap: CGFloat = 24
        static let cardPadding: CGFloat = 16
        static let itemSpacing: CGFloat = 12
        static let smallSpacing: CGFloat = 8
        static let tinySpacing: CGFloat = 4
    }

    enum IconSize {
        static let topicIcon: CGFloat = 20
        static let micButton: CGFloat = 64
        static let navIcon: CGFloat = 22
    }

    enum Fonts {
        static let appTitle = Font.title.bold()
        static let appSubtitle = Font.subheadline
        static let sectionHeader = Font.caption.weight(.semibold)
        static let topicTitle = Font.headline
        static let topicSubtitle = Font.subheadline
        static let topicMeta = Font.caption
        static let entryBody = Font.body
        static let entryTimestamp = Font.caption2
        static let aiBadge = Font.caption2.weight(.bold)
    }
}
