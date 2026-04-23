import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject private var env: AppEnvironment
    @Environment(\.openWindow) private var openWindow

    private var completedCount: Int { env.todos.filter(\.isCompleted).count }
    private var totalCount: Int { env.todos.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if totalCount > 0 {
                Text(verbatim: String(format: env.ls("menubar_progress"), completedCount, totalCount))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 6)
                    .padding(.bottom, 2)
            }

            Divider()

            Button(env.ls("menu_open_app")) {
                NSApp.setActivationPolicy(.regular)
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    NSApp.windows
                        .first { $0.identifier?.rawValue == "main" }?
                        .makeKeyAndOrderFront(nil)
                }
            }

            Button(env.ls("menu_start_break")) {
                env.coordinator.triggerManually()
            }
            .disabled(env.coordinator.isOverlayVisible)

            Divider()

            SettingsLink {
                Text(verbatim: env.ls("menu_settings"))
            }

            Divider()

            Button(env.ls("menu_quit")) {
                NSApp.terminate(nil)
            }
        }
        .environment(\.locale, env.appLocale)
        .onAppear { env.loadTodaysTodos() }
    }
}
