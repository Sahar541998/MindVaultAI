import Foundation
import SwiftData

@Observable
final class HomeViewModel {

    var searchText = ""

    func filteredTopics(from topics: [Topic]) -> [Topic] {
        guard !searchText.isEmpty else {
            return topics.sorted { $0.lastActivityDate > $1.lastActivityDate }
        }
        let query = searchText.lowercased()
        return topics
            .filter { $0.title.lowercased().contains(query) }
            .sorted { $0.lastActivityDate > $1.lastActivityDate }
    }

    func createTopic(title: String, icon: String, context: ModelContext) -> Topic {
        let topic = Topic(title: title, icon: icon, accentColorIndex: Int.random(in: 0..<8))
        context.insert(topic)
        return topic
    }

    func deleteTopic(_ topic: Topic, context: ModelContext) {
        context.delete(topic)
    }
}
