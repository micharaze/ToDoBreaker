import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject private var env: AppEnvironment
    @Environment(\.openWindow) private var openWindow

    private var completedCount: Int { env.todos.filter(\.isCompleted).count }
    private var totalCount: Int { env.todos.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if totalCount > 0 {
                Text("\(completedCount) / \(totalCount) erledigt")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 6)
                    .padding(.bottom, 2)
            }

            Divider()

            Button("ToDos anzeigen") {
                NSApp.setActivationPolicy(.regular)
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
            }

            Button("Morning Break starten") {
                env.coordinator.triggerManually()
            }
            .disabled(env.coordinator.isOverlayVisible)

            Divider()

            SettingsLink {
                Text("Einstellungen")
            }

            Divider()

            Button("Beenden") {
                NSApp.terminate(nil)
            }
        }
        .onAppear { env.loadTodaysTodos() }
    }
}
