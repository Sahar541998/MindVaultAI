import SwiftUI

struct AskAISheet: View {

    @Binding var questionText: String
    let isAsking: Bool
    let onSubmit: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    private var canSubmit: Bool {
        !questionText.trimmingCharacters(in: .whitespaces).isEmpty && !isAsking
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.sectionGap) {
                VStack(spacing: AppTheme.Spacing.smallSpacing) {
                    Image(systemName: "questionmark.bubble.fill")
                        .font(.largeTitle)
                        .foregroundStyle(AppColors.accentPurple)

                    Text("Ask AI")
                        .font(AppTheme.Fonts.appTitle)
                        .foregroundStyle(AppColors.textPrimary)

                    Text("Ask anything about your entries in this topic")
                        .font(AppTheme.Fonts.appSubtitle)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                TextField("What would you like to know?", text: $questionText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .lineLimit(2...6)
                    .padding(AppTheme.Spacing.cardPadding)
                    .background(AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.searchBar))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.searchBar)
                            .stroke(AppColors.cardBorder, lineWidth: 1)
                    )

                Button(action: { onSubmit(questionText.trimmingCharacters(in: .whitespaces)) }) {
                    HStack(spacing: AppTheme.Spacing.smallSpacing) {
                        if isAsking {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(isAsking ? "Thinking..." : "Ask")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(canSubmit ? AppColors.accentPurple : AppColors.textSecondary.opacity(0.3))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.button))
                }
                .disabled(!canSubmit)
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, AppTheme.Spacing.sectionGap)
            .background(AppColors.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .accessibilityLabel("Cancel")
                }
            }
            .onAppear { isFocused = true }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .presentationDetents([.medium])
            .presentationBackground(AppColors.background)
        }
    }
}

#Preview {
    AskAISheet(
        questionText: .constant(""),
        isAsking: false,
        onSubmit: { _ in }
    )
    .modelContainer(PreviewSampleData.emptyContainer)
}
