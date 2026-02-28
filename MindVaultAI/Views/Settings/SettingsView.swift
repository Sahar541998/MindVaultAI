import SwiftUI

struct SettingsView: View {

    @Environment(\.dismiss) private var dismiss
    @AppStorage("appearance") private var appearance: String = "system"

    var body: some View {
        NavigationStack {
            Form {
                appearanceSection
                aiStatusSection
                aboutSection
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $appearance) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .pickerStyle(.segmented)
        }
    }

    private var aiStatusSection: some View {
        Section("AI Features") {
            HStack {
                Image(systemName: AIService.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(AIService.isAvailable ? .green : .red)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Apple Intelligence")
                        .font(AppTheme.Fonts.topicTitle)
                    Text(AIService.isAvailable
                         ? "Available on this device"
                         : "Not available — requires Apple Silicon")
                        .font(AppTheme.Fonts.topicMeta)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}

#Preview {
    SettingsView()
}
