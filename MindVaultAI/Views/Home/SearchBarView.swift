import SwiftUI

struct SearchBarView: View {

    @Binding var searchText: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: AppTheme.Spacing.smallSpacing) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.textSecondary)

            TextField("Search topics...", text: $searchText)
                .textFieldStyle(.plain)
                .foregroundStyle(AppColors.textPrimary)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit { isFocused = false }

            if isFocused || !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isFocused = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(AppTheme.Spacing.itemSpacing)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.searchBar))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.searchBar)
                .stroke(AppColors.cardBorder, lineWidth: 1)
        )
    }
}

#Preview {
    SearchBarView(searchText: .constant(""))
        .padding()
        .background(AppColors.background)
}

#Preview("With Text") {
    SearchBarView(searchText: .constant("Sprint"))
        .padding()
        .background(AppColors.background)
}
