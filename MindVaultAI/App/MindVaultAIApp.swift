import SwiftUI
import SwiftData

@main
struct MindVaultAIApp: App {

    @AppStorage("appearance") private var appearance: String = "system"

    let modelContainer: ModelContainer = {
        let config = ModelConfiguration(cloudKitDatabase: .automatic)
        return try! ModelContainer(for: Topic.self, Entry.self, configurations: config)
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(colorScheme)
        }
        .modelContainer(modelContainer)
    }

    private var colorScheme: ColorScheme? {
        switch appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
