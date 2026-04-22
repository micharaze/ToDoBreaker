import SwiftUI

@main
struct ToDoBreakerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Main window
        WindowGroup("ToDoBreaker", id: "main") {
            MainWindowView()
                .environmentObject(appDelegate.environment)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            // Remove "New Window" from File menu — this is a single-window app.
            CommandGroup(replacing: .newItem) {}
        }

        // Menu bar icon + popover
        MenuBarExtra("ToDoBreaker", systemImage: "checkmark.circle.fill") {
            MenuBarContentView()
                .environmentObject(appDelegate.environment)
        }

        // Settings window (opens via Cmd+, or menu)
        Settings {
            SettingsView()
                .environmentObject(appDelegate.environment)
        }
    }
}
