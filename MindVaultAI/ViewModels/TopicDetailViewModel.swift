import Foundation
import SwiftData

@Observable
final class TopicDetailViewModel {

    var isGeneratingSummary = false
    var errorMessage: String?

    private let aiService = AIService()

    func addEntry(text: String, to topic: Topic, context: ModelContext) {
        let entry = Entry(text: text, topic: topic)
        topic.updatedAt = Date()
        context.insert(entry)

        if AIService.isAvailable {
            Task {
                await generateSummary(for: topic, context: context)
            }
        }
    }

    @MainActor
    func generateSummary(for topic: Topic, context: ModelContext) async {
        let userEntries = (topic.entries ?? []).filter { !$0.isAISummary }
        guard !userEntries.isEmpty else { return }

        isGeneratingSummary = true
        defer { isGeneratingSummary = false }

        do {
            let summary = try await aiService.summarize(entries: userEntries)

            let existing = (topic.entries ?? []).filter { $0.isAISummary }
            for old in existing {
                context.delete(old)
            }

            let summaryEntry = Entry(text: summary, isAISummary: true, topic: topic)
            context.insert(summaryEntry)
            topic.updatedAt = Date()
        } catch {
            errorMessage = "Could not generate summary: \(error.localizedDescription)"
        }
    }
}
