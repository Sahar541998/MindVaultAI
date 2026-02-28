import SwiftUI
import SwiftData

@main
struct MindVaultAIApp: App {

    @AppStorage("appearance") private var appearance: String = "system"

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(colorScheme)
        }
        .modelContainer(for: [Topic.self, Entry.self], cloudKitDatabase: .automatic)
    }

    private var colorScheme: ColorScheme? {
        switch appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
