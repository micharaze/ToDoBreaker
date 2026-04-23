import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let environment = AppEnvironment()

    private var wakeObserver: Any?
    private var windowDidBecomeKeyObserver: Any?
    private var windowWillCloseObserver: Any?
    private var isLaunching = true

    private func isMainWindow(_ window: NSWindow) -> Bool {
        if let id = window.identifier?.rawValue, id == "main" {
            return true
        }
        return window.title == "ToDoBreaker"
    }

    private func updateActivationPolicyForVisibleWindows(excluding windowToExclude: NSWindow? = nil) {
        let hasVisibleMainWindow = NSApp.windows.contains {
            isMainWindow($0) && $0.isVisible && $0 !== windowToExclude
        }
        NSApp.setActivationPolicy(hasVisibleMainWindow ? .regular : .accessory)
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        environment.coordinator.startTimer()
        environment.coordinator.checkIfBreakNeeded()

        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.environment.coordinator.checkIfBreakNeeded()
            }
        }

        // Show Dock icon when user opens a window — ignore auto-restored windows on launch.
        windowDidBecomeKeyObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let window = notification.object as? NSWindow,
                  !(window is OverlayWindow) else { return }
            Task { @MainActor [weak self] in
                guard let self, !self.isLaunching, self.isMainWindow(window) else { return }
                NSApp.setActivationPolicy(.regular)
            }
        }

        // Hide Dock icon when all regular windows are closed.
        windowWillCloseObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let closing = notification.object as? NSWindow,
                  !(closing is OverlayWindow) else { return }
            Task { @MainActor in
                // Run on the next runloop so AppKit has already updated visibility.
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if self.isMainWindow(closing) {
                        NSApp.setActivationPolicy(.accessory)
                    } else {
                        self.updateActivationPolicyForVisibleWindows(excluding: closing)
                    }
                }
            }
        }

        // SwiftUI sets .regular internally when creating WindowGroup windows.
        // Re-apply .accessory after it, then hide any auto-restored windows.
        Task { @MainActor [weak self] in
            NSApp.windows
                .filter { !($0 is OverlayWindow) }
                .forEach { $0.orderOut(nil) }
            NSApp.setActivationPolicy(.accessory)
            self?.isLaunching = false
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
        if let obs = windowDidBecomeKeyObserver {
            NotificationCenter.default.removeObserver(obs)
        }
        if let obs = windowWillCloseObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }
}
