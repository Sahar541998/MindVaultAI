import SwiftData
import Foundation

@MainActor
enum PreviewSampleData {

    static var container: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Topic.self, Entry.self,
            configurations: config
        )
        addSampleData(to: container.mainContext)
        return container
    }

    static var emptyContainer: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(
            for: Topic.self, Entry.self,
            configurations: config
        )
    }

    static func addSampleData(to context: ModelContext) {
        let sarah = Topic(title: "Sarah — Performance & Tasks", icon: "person.fill", accentColorIndex: 0)
        context.insert(sarah)

        context.insert(Entry(text: "Sarah completed the API integration task two days ahead of schedule. Very impressive turnaround.", topic: sarah))
        context.insert(Entry(
            text: "Sarah has consistently delivered ahead of schedule across 3 recent tasks. She shows strong initiative in helping teammates and has been instrumental in onboarding.",
            isAISummary: true,
            topic: sarah
        ))
        context.insert(Entry(
            text: "She helped the new developer Jake get set up with the codebase. Spent about 2 hours pair programming with him.",
            createdAt: Date().addingTimeInterval(-86400),
            topic: sarah
        ))
        context.insert(Entry(
            text: "Sarah mentioned she's interested in leading the next sprint planning session. I think she'd be great at it.",
            createdAt: Date().addingTimeInterval(-172800),
            topic: sarah
        ))
        context.insert(Entry(
            text: "Performance review note: Sarah exceeds expectations in both technical delivery and team collaboration. Consider for tech lead promotion track.",
            isAISummary: true,
            createdAt: Date().addingTimeInterval(-604800),
            topic: sarah
        ))

        let sprint = Topic(title: "Sprint 14 Blockers", icon: "chevron.left.forwardslash.chevron.right", accentColorIndex: 1)
        context.insert(sprint)
        context.insert(Entry(text: "Database migration pending review. CI/CD pipeline timeout issues need investigation.", topic: sprint))

        let standup = Topic(title: "Team Standup Notes", icon: "calendar", accentColorIndex: 3)
        context.insert(standup)
        context.insert(Entry(text: "Frontend team ahead of schedule. Backend needs support on auth module.", topic: standup))

        let david = Topic(title: "1:1 with David", icon: "bubble.left.fill", accentColorIndex: 5)
        context.insert(david)
        context.insert(Entry(text: "Wants to transition to full-stack role. Interested in mentoring juniors.", createdAt: Date().addingTimeInterval(-86400), topic: david))
    }

    static var sampleTopic: Topic {
        let topic = Topic(title: "Sarah — Performance & Tasks", icon: "person.fill", accentColorIndex: 0)
        return topic
    }

    static func sampleEntry(isSummary: Bool = false) -> Entry {
        if isSummary {
            return Entry(
                text: "Sarah has consistently delivered ahead of schedule across 3 recent tasks. She shows strong initiative in helping teammates and has been instrumental in onboarding.",
                isAISummary: true
            )
        }
        return Entry(text: "Sarah completed the API integration task two days ahead of schedule. Very impressive turnaround.")
    }
}
