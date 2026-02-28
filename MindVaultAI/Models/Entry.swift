import Foundation
import SwiftData

@Model
final class Entry {
    var id: UUID = UUID()
    var text: String = ""
    var isAISummary: Bool = false
    var isAIAnswer: Bool = false
    var question: String = ""
    var createdAt: Date = Date()
    var topic: Topic? = nil

    init(
        text: String = "",
        isAISummary: Bool = false,
        isAIAnswer: Bool = false,
        question: String = "",
        createdAt: Date = Date(),
        topic: Topic? = nil
    ) {
        self.id = UUID()
        self.text = text
        self.isAISummary = isAISummary
        self.isAIAnswer = isAIAnswer
        self.question = question
        self.createdAt = createdAt
        self.topic = topic
    }
}
