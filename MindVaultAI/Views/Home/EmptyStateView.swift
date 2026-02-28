import SwiftUI

struct EmptyStateView: View {

    var onRecordTapped: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sectionGap) {
            Spacer()

            Image(systemName: "brain.head.profile")
                .font(.system(size: 64))
                .foregroundStyle(AppColors.accentTeal.opacity(0.6))

            VStack(spacing: AppTheme.Spacing.smallSpacing) {
                Text("No topics yet")
                    .font(AppTheme.Fonts.topicTitle)
                    .foregroundStyle(AppColors.textPrimary)

                Text("Tap the mic to record your first thought")
                    .font(AppTheme.Fonts.topicSubtitle)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onRecordTapped) {
                Label("Record your first thought", systemImage: "mic.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(AppColors.micGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(onRecordTapped: {})
        .background(AppColors.background)
}
