import SwiftUI
import SwiftData

struct EntryRowView: View {

    let entry: Entry

    var body: some View {
        if entry.isAIAnswer {
            aiAnswerView
        } else if entry.isAISummary {
            aiSummaryView
        } else {
            userEntryView
        }
    }

    private var userEntryView: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.smallSpacing) {
            Text(entry.text)
                .font(AppTheme.Fonts.entryBody)
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: AppTheme.Spacing.tinySpacing) {
                Image(systemName: "clock")
                Text(entry.createdAt.relativeFormatted)
            }
            .font(AppTheme.Fonts.entryTimestamp)
            .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppTheme.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.entryBubble))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.entryBubble)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }

    private var aiSummaryView: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.smallSpacing) {
            Text("AI SUMMARY")
                .font(AppTheme.Fonts.aiBadge)
                .foregroundStyle(AppColors.accentTeal)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(AppColors.accentTeal.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 4))

            Text(entry.text)
                .font(AppTheme.Fonts.entryBody)
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: AppTheme.Spacing.tinySpacing) {
                Image(systemName: "clock")
                Text(entry.createdAt.relativeFormatted)
            }
            .font(AppTheme.Fonts.entryTimestamp)
            .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppTheme.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.accentTeal.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.entryBubble))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.entryBubble)
                .stroke(AppColors.accentTeal.opacity(0.3), lineWidth: 1)
        )
    }
    private var aiAnswerView: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.smallSpacing) {
            Text("AI ANSWER")
                .font(AppTheme.Fonts.aiBadge)
                .foregroundStyle(AppColors.accentPurple)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(AppColors.accentPurple.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 4))

            if !entry.question.isEmpty {
                Text(entry.question)
                    .font(AppTheme.Fonts.entryBody.italic())
                    .foregroundStyle(AppColors.textSecondary)
            }

            Text(entry.text)
                .font(AppTheme.Fonts.entryBody)
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: AppTheme.Spacing.tinySpacing) {
                Image(systemName: "clock")
                Text(entry.createdAt.relativeFormatted)
            }
            .font(AppTheme.Fonts.entryTimestamp)
            .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppTheme.Spacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.accentPurple.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.entryBubble))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.entryBubble)
                .stroke(AppColors.accentPurple.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview("User Entry") {
    EntryRowView(entry: PreviewSampleData.sampleEntry())
        .padding()
        .background(AppColors.background)
        .modelContainer(PreviewSampleData.emptyContainer)
}

#Preview("AI Summary") {
    EntryRowView(entry: PreviewSampleData.sampleEntry(isSummary: true))
        .padding()
        .background(AppColors.background)
        .modelContainer(PreviewSampleData.emptyContainer)
}
