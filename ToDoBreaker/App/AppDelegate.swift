import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    // Initialized before the SwiftUI scene body is evaluated.
    let environment = AppEnvironment()

    private var wakeObserver: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Start the 60-second break check timer.
        environment.coordinator.startTimer()

        // Immediate check on launch (handles case where app starts after configured time).
        environment.coordinator.checkIfBreakNeeded()

        // System wake = fast path to trigger the break check without waiting for the timer.
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.environment.coordinator.checkIfBreakNeeded()
            }
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        // Third safety net: also check when the app becomes active.
        environment.coordinator.checkIfBreakNeeded()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep running in the menu bar even if all windows are closed.
        false
    }

    deinit {
        if let obs = wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(obs)
        }
    }
}
