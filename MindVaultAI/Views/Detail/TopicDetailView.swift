import SwiftUI
import SwiftData

struct TopicDetailView: View {

    let topic: Topic

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TopicDetailViewModel()
    @State private var newEntryText = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            entriesList
            addEntryBar
        }
        .background(AppColors.background)
        .navigationTitle(topic.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar { toolbarItems }
        .alert("Error", isPresented: showErrorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var entriesList: some View {
        List {
            Section {
                detailHeader
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))

            Section {
                if viewModel.isGeneratingSummary {
                    ProgressView("Generating AI summary...")
                        .padding()
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                ForEach(topic.sortedEntries) { entry in
                    EntryRowView(entry: entry)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteEntry(entry)
                            } label: {
                                Label("Delete entry", systemImage: "xmark")
                            }
                        }
                }
            }

            Color.clear
                .frame(height: 80)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var detailHeader: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tinySpacing) {
            HStack(spacing: AppTheme.Spacing.smallSpacing) {
                Image(systemName: topic.icon)
                    .foregroundStyle(accentColor)
                Text(topic.title)
                    .font(AppTheme.Fonts.appTitle)
                    .foregroundStyle(AppColors.textPrimary)
            }
            Text("\(topic.entryCount) entries")
                .font(AppTheme.Fonts.topicMeta)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.top)
    }

    private var addEntryBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: AppTheme.Spacing.smallSpacing) {
                TextField("Add a thought...", text: $newEntryText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .focused($isTextFieldFocused)
                    .lineLimit(1...4)

                Button(action: submitEntry) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            newEntryText.trimmingCharacters(in: .whitespaces).isEmpty
                                ? AppColors.textSecondary
                                : AppColors.accentTeal
                        )
                }
                .disabled(newEntryText.trimmingCharacters(in: .whitespaces).isEmpty)
                .buttonStyle(.plain)
                .accessibilityLabel("Send entry")
            }
            .padding(.horizontal)
            .padding(.vertical, AppTheme.Spacing.itemSpacing)
            .background(.ultraThinMaterial)
        }
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            if AIService.isAvailable {
                Button(action: { Task { await generateSummary() } }) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(AppColors.accentTeal)
                }
                .disabled(viewModel.isGeneratingSummary)
                .accessibilityLabel("Generate AI summary")
            }
        }
    }

    private var accentColor: Color {
        AppColors.topicAccentColors[topic.accentColorIndex % AppColors.topicAccentColors.count]
    }

    private var showErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }

    private func submitEntry() {
        let text = newEntryText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        viewModel.addEntry(text: text, to: topic, context: modelContext)
        newEntryText = ""
        isTextFieldFocused = false
    }

    private func deleteEntry(_ entry: Entry) {
        modelContext.delete(entry)
        topic.updatedAt = Date()
    }

    private func generateSummary() async {
        await viewModel.generateSummary(for: topic, context: modelContext)
    }
}

#Preview {
    NavigationStack {
        TopicDetailView(topic: PreviewSampleData.sampleTopic)
    }
    .modelContainer(PreviewSampleData.container)
}
