import SwiftUI
import SwiftData

struct TopicPickerSheet: View {

    let text: String
    var onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Topic.updatedAt, order: .reverse) private var topics: [Topic]

    @State private var newTopicTitle = ""
    @State private var isCreatingNew = false
    @State private var aiService = AIService()
    @State private var aiSuggestedTopicTitle: String?
    @State private var aiSuggestedNewName: String?
    @State private var isSuggesting = true

    var body: some View {
        NavigationStack {
            List {
                aiSuggestionSection
                existingTopicsSection
                createNewSection
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #endif
            .navigationTitle("Choose a topic")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay {
                if isCreatingNew {
                    ProgressView("Creating topic...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
            .task { await suggestTopic() }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - AI Suggestion Section

    @ViewBuilder
    private var aiSuggestionSection: some View {
        if isSuggesting {
            Section {
                HStack(spacing: AppTheme.Spacing.itemSpacing) {
                    ProgressView()
                    Text("Suggesting topic...")
                        .font(AppTheme.Fonts.topicSubtitle)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        } else if let matchedTitle = aiSuggestedTopicTitle,
                  let matchedTopic = topics.first(where: { $0.title == matchedTitle }) {
            Section("AI Suggestion") {
                Button(action: { assignToTopic(matchedTopic) }) {
                    HStack(spacing: AppTheme.Spacing.itemSpacing) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(AppColors.accentTeal)
                        Image(systemName: matchedTopic.icon)
                            .foregroundStyle(accentColor(for: matchedTopic))
                            .frame(width: 28)
                        Text(matchedTopic.title)
                            .font(AppTheme.Fonts.topicTitle)
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Text("\(matchedTopic.entryCount)")
                            .font(AppTheme.Fonts.topicMeta)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Existing Topics

    @ViewBuilder
    private var existingTopicsSection: some View {
        if !topics.isEmpty {
            Section("Existing Topics") {
                ForEach(topics) { topic in
                    Button(action: { assignToTopic(topic) }) {
                        HStack(spacing: AppTheme.Spacing.itemSpacing) {
                            Image(systemName: topic.icon)
                                .foregroundStyle(accentColor(for: topic))
                                .frame(width: 28)
                            Text(topic.title)
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                            Text("\(topic.entryCount)")
                                .font(AppTheme.Fonts.topicMeta)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Create New

    private var createNewSection: some View {
        Section("Create New Topic") {
            HStack {
                TextField("Topic title", text: $newTopicTitle)
                    .textFieldStyle(.plain)
                Button(action: createNewTopic) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(
                            newTopicTitle.trimmingCharacters(in: .whitespaces).isEmpty
                                ? AppColors.textSecondary
                                : AppColors.accentTeal
                        )
                }
                .disabled(newTopicTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Actions

    private func accentColor(for topic: Topic) -> Color {
        AppColors.topicAccentColors[topic.accentColorIndex % AppColors.topicAccentColors.count]
    }

    @MainActor
    private func suggestTopic() async {
        guard AIService.isAvailable else {
            isSuggesting = false
            return
        }

        let topicTitles = topics.map(\.title)
        do {
            let result = try await aiService.categorize(text: text, existingTopics: topicTitles)
            switch result {
            case .matched(let title):
                aiSuggestedTopicTitle = title
            case .newTopicSuggestion(let suggested):
                if !suggested.isEmpty {
                    aiSuggestedNewName = suggested
                    newTopicTitle = suggested
                }
            }
        } catch {
            // AI suggestion is non-critical; user can still pick manually
        }
        isSuggesting = false
    }

    private func assignToTopic(_ topic: Topic) {
        let entry = Entry(text: text, topic: topic)
        topic.updatedAt = Date()
        modelContext.insert(entry)

        if AIService.isAvailable {
            let vm = TopicDetailViewModel()
            Task {
                await vm.generateSummary(for: topic, context: modelContext)
            }
        }

        dismiss()
        onComplete()
    }

    private func createNewTopic() {
        let title = newTopicTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }

        isCreatingNew = true

        Task { @MainActor in
            var icon = "brain.head.profile"
            if AIService.isAvailable {
                do {
                    icon = try await aiService.suggestIcon(for: title)
                } catch {}
            }

            let topic = Topic(
                title: title,
                icon: icon,
                accentColorIndex: Int.random(in: 0..<AppColors.topicAccentColors.count)
            )
            modelContext.insert(topic)

            let entry = Entry(text: text, topic: topic)
            modelContext.insert(entry)

            if AIService.isAvailable {
                let vm = TopicDetailViewModel()
                await vm.generateSummary(for: topic, context: modelContext)
            }

            isCreatingNew = false
            dismiss()
            onComplete()
        }
    }
}

#Preview {
    TopicPickerSheet(text: "Need to review the database migration", onComplete: {})
        .modelContainer(PreviewSampleData.container)
}
