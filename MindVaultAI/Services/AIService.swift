import Foundation
import FoundationModels
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@Observable
final class AIService {

    private(set) var isProcessing = false

    static var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }

    // MARK: - Summarize

    private static let summaryInstructions = """
    You are a concise note summarizer. Given the following entries from a topic, \
    write a brief 1-3 sentence summary capturing the key points. \
    Do not add any preamble or labels -- just the summary text.
    """

    func summarize(entries: [Entry]) async throws -> String {
        let session = LanguageModelSession(instructions: Self.summaryInstructions)
        let entriesText = entries
            .filter { !$0.isAISummary }
            .sorted { $0.createdAt < $1.createdAt }
            .map { $0.text }
            .joined(separator: "\n- ")

        let prompt = "Entries:\n- \(entriesText)"
        isProcessing = true
        defer { isProcessing = false }

        let response = try await session.respond(to: prompt)
        return response.content
    }

    // MARK: - Categorize

    enum CategorizeResult {
        case matched(topicTitle: String)
        case newTopicSuggestion(suggestedTitle: String)
    }

    private static let categorizeInstructions = """
    You are a topic classifier. Given a new entry and a list of existing topic titles, \
    decide where this entry belongs. \
    If it fits an existing topic (>80% confidence), respond with EXACTLY: MATCH: <exact topic title> \
    If it doesn't fit any existing topic, suggest a short new topic name. \
    Respond with EXACTLY: NEW: <suggested topic name> \
    Do not add any explanation, only one line.
    """

    func categorize(text: String, existingTopics: [String]) async throws -> CategorizeResult {
        let session = LanguageModelSession(instructions: Self.categorizeInstructions)
        let topicList = existingTopics.isEmpty
            ? "(no existing topics)"
            : existingTopics.joined(separator: ", ")

        let prompt = "Existing topics: \(topicList)\n\nNew entry: \(text)"

        isProcessing = true
        defer { isProcessing = false }

        let response = try await session.respond(to: prompt)
        let answer = response.content.trimmingCharacters(in: .whitespacesAndNewlines)

        if answer.hasPrefix("MATCH:") {
            let title = answer.replacingOccurrences(of: "MATCH:", with: "").trimmingCharacters(in: .whitespaces)
            if existingTopics.contains(title) {
                return .matched(topicTitle: title)
            }
        }

        if answer.hasPrefix("NEW:") {
            let suggested = answer.replacingOccurrences(of: "NEW:", with: "").trimmingCharacters(in: .whitespaces)
            if !suggested.isEmpty {
                return .newTopicSuggestion(suggestedTitle: suggested)
            }
        }

        return .newTopicSuggestion(suggestedTitle: "")
    }

    // MARK: - Ask Question

    private static let questionInstructions = """
    You are a helpful assistant. The user has a collection of personal notes/entries \
    on a specific topic. Given those entries as context, answer the user's question \
    thoughtfully and concisely. Base your answer on the provided entries. \
    If the entries don't contain enough information, say so honestly. \
    Do not add any preamble or labels -- just the answer.
    """

    func askQuestion(_ question: String, entries: [Entry]) async throws -> String {
        let session = LanguageModelSession(instructions: Self.questionInstructions)
        let entriesText = entries
            .filter { !$0.isAISummary && !$0.isAIAnswer }
            .sorted { $0.createdAt < $1.createdAt }
            .map { $0.text }
            .joined(separator: "\n- ")

        let prompt = "Entries:\n- \(entriesText)\n\nQuestion: \(question)"
        isProcessing = true
        defer { isProcessing = false }

        let response = try await session.respond(to: prompt)
        return response.content
    }

    // MARK: - Suggest Icon

    private static let iconInstructions = """
    You are an SF Symbol picker. Given a topic title, respond with ONLY a single \
    SF Symbol name that best represents this topic. Use common symbols like: \
    person.fill, chevron.left.forwardslash.chevron.right, calendar, \
    bubble.left.fill, doc.text, gear, star.fill, heart.fill, lightbulb.fill, \
    chart.bar.fill, airplane, book.fill, music.note, camera.fill, \
    flag.fill, bell.fill, mappin, cart.fill, briefcase.fill. \
    Respond with ONLY the symbol name, nothing else.
    """

    func suggestIcon(for title: String) async throws -> String {
        let session = LanguageModelSession(instructions: Self.iconInstructions)
        let prompt = "Topic title: \(title)"

        isProcessing = true
        defer { isProcessing = false }

        let response = try await session.respond(to: prompt)
        let symbol = response.content.trimmingCharacters(in: .whitespacesAndNewlines)

        if systemImageExists(symbol) {
            return symbol
        }
        return "brain.head.profile"
    }

    private func systemImageExists(_ name: String) -> Bool {
        #if canImport(UIKit)
        return UIImage(systemName: name) != nil
        #elseif canImport(AppKit)
        return NSImage(systemSymbolName: name, accessibilityDescription: nil) != nil
        #else
        return false
        #endif
    }
}
