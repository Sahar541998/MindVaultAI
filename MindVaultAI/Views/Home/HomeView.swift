import SwiftUI
import SwiftData

struct HomeView: View {

    @Query(sort: \Topic.updatedAt, order: .reverse) private var topics: [Topic]
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()
    @State private var showVoiceInput = false
    @State private var showSettings = false

    var body: some View {
        NavigationSplitView {
            sidebarContent
                .navigationTitle("")
                .toolbar { toolbarItems }
        } detail: {
            Text("Select a topic")
                .foregroundStyle(AppColors.textSecondary)
        }
        .sheet(isPresented: $showVoiceInput) {
            VoiceInputSheet()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private var sidebarContent: some View {
        ZStack(alignment: .bottom) {
            topicList
            micButton
        }
    }

    @ViewBuilder
    private var topicList: some View {
        let filtered = viewModel.filteredTopics(from: topics)

        List {
            Section {
                headerView
                SearchBarView(searchText: $viewModel.searchText)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16))

            if topics.isEmpty {
                Section {
                    EmptyStateView(onRecordTapped: { showVoiceInput = true })
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                Section {
                    Text("TOPICS (\(filtered.count))")
                        .font(AppTheme.Fonts.sectionHeader)
                        .foregroundStyle(AppColors.textSecondary)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)

                    if filtered.isEmpty {
                        Text("No topics match your search")
                            .font(AppTheme.Fonts.topicSubtitle)
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, AppTheme.Spacing.sectionGap)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } else {
                        ForEach(filtered) { topic in
                            ZStack {
                                NavigationLink(value: topic) {
                                    EmptyView()
                                }
                                .opacity(0)

                                TopicRowView(topic: topic)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteTopic(topic, context: modelContext)
                                } label: {
                                    Label("Delete topic", systemImage: "xmark")
                                }
                            }
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
        .scrollDismissesKeyboard(.interactively)
        .background(AppColors.background)
        .navigationDestination(for: Topic.self) { topic in
            TopicDetailView(topic: topic)
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tinySpacing) {
            HStack(spacing: AppTheme.Spacing.smallSpacing) {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundStyle(AppColors.accentTeal)
                Text("MindVaultAI")
                    .font(AppTheme.Fonts.appTitle)
                    .foregroundStyle(AppColors.textPrimary)
            }
            Text("Your AI-powered memory layer")
                .font(AppTheme.Fonts.appSubtitle)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.top, 4)
    }

    private var micButton: some View {
        Button(action: { showVoiceInput = true }) {
            Image(systemName: "mic.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: AppTheme.IconSize.micButton, height: AppTheme.IconSize.micButton)
                .background(AppColors.micGradient)
                .clipShape(Circle())
                .shadow(color: AppColors.accentPurple.opacity(0.4), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.bottom, AppTheme.Spacing.sectionGap)
        .accessibilityLabel("Record a new thought")
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape")
                    .foregroundStyle(AppColors.textSecondary)
            }
            .accessibilityLabel("Settings")
        }
    }
}

#Preview("With Topics") {
    HomeView()
        .modelContainer(PreviewSampleData.container)
}

#Preview("Empty State") {
    HomeView()
        .modelContainer(PreviewSampleData.emptyContainer)
}
