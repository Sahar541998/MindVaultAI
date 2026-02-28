import Foundation
import SwiftData

@Model
final class Topic {
    var id: UUID = UUID()
    var title: String = ""
    var icon: String = "brain.head.profile"
    var accentColorIndex: Int = 0
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \Entry.topic)
    var entries: [Entry]? = nil

    init(
        title: String = "",
        icon: String = "brain.head.profile",
        accentColorIndex: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.icon = icon
        self.accentColorIndex = accentColorIndex
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var sortedEntries: [Entry] {
        (entries ?? []).sorted { $0.createdAt > $1.createdAt }
    }

    var entryCount: Int {
        (entries ?? []).count
    }

    var lastEntrySnippet: String {
        guard let latest = sortedEntries.first else { return "No entries yet" }
        let limit = 80
        if latest.text.count <= limit { return latest.text }
        return String(latest.text.prefix(limit)) + "..."
    }

    var lastActivityDate: Date {
        sortedEntries.first?.createdAt ?? updatedAt
    }
}
