import SwiftUI

@main
struct ZeroSixAppApp: App {
    @StateObject private var settingsStore = SettingsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsStore)
        }
        .windowStyle(.automatic)

        Settings {
            SettingsPane()
                .environmentObject(settingsStore)
        }
    }
}
