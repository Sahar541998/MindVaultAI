import SwiftUI
import SwiftData

struct TopicRowView: View {

    let topic: Topic

    private var accentColor: Color {
        let colors = AppColors.topicAccentColors
        return colors[topic.accentColorIndex % colors.count]
    }

    var body: some View {
        HStack(spacing: 0) {
            accentColor
                .frame(width: 4)

            HStack(spacing: AppTheme.Spacing.itemSpacing) {
                iconView
                contentView
                Spacer(minLength: 0)
            }
            .padding(AppTheme.Spacing.cardPadding)
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }

    private var iconView: some View {
        Image(systemName: topic.icon)
            .font(.system(size: AppTheme.IconSize.topicIcon))
            .foregroundStyle(accentColor)
            .frame(width: 36, height: 36)
            .background(accentColor.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tinySpacing) {
            Text(topic.title)
                .font(AppTheme.Fonts.topicTitle)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)

            Text(topic.lastEntrySnippet)
                .font(AppTheme.Fonts.topicSubtitle)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)

            HStack(spacing: AppTheme.Spacing.smallSpacing) {
                Text("\(topic.entryCount) entries")
                Text("·")
                Text(topic.lastActivityDate.relativeFormatted)
            }
            .font(AppTheme.Fonts.topicMeta)
            .foregroundStyle(AppColors.textSecondary)
        }
    }


}

#Preview {
    TopicRowView(topic: PreviewSampleData.sampleTopic)
        .padding()
        .background(AppColors.background)
        .modelContainer(PreviewSampleData.container)
}
