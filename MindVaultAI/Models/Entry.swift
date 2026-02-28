import Foundation
import SwiftData

@Model
final class Entry {
    var id: UUID = UUID()
    var text: String = ""
    var isAISummary: Bool = false
    var createdAt: Date = Date()
    var topic: Topic? = nil

    init(
        text: String = "",
        isAISummary: Bool = false,
        createdAt: Date = Date(),
        topic: Topic? = nil
    ) {
        self.id = UUID()
        self.text = text
        self.isAISummary = isAISummary
        self.createdAt = createdAt
        self.topic = topic
    }
}
