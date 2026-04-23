import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let environment = AppEnvironment()

    private var wakeObserver: Any?
    private var windowDidBecomeKeyObserver: Any?
    private var windowWillCloseObserver: Any?
    private var isLaunching = true

    private func isMainWindow(_ window: NSWindow) -> Bool {
        if let id = window.identifier?.rawValue, id == "main" { return true }
        return window.title == "ToDoBreaker"
    }

    private func isUserFacingWindow(_ window: NSWindow) -> Bool {
        !(window is OverlayWindow) &&
        window.styleMask.contains(.titled) &&
        !window.isMiniaturized
    }

    private func updateActivationPolicyForVisibleWindows(excluding windowToExclude: NSWindow? = nil) {
        let hasVisible = NSApp.windows.contains {
            isUserFacingWindow($0) && $0.isVisible && $0 !== windowToExclude
        }
        NSApp.setActivationPolicy(hasVisible ? .regular : .accessory)
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

        // Titled (non-popover) window becoming key → show Dock icon.
        windowDidBecomeKeyObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor [weak self] in
                guard let self,
                      let window = notification.object as? NSWindow,
                      self.isUserFacingWindow(window),
                      !self.isLaunching else { return }
                NSApp.setActivationPolicy(.regular)
            }
        }

        // Hide Dock icon when all titled windows are closed.
        // Ignoring popover/panel windows (e.g. the menu bar extra popover)
        // prevents them from accidentally resetting the activation policy
        // while a real window is being shown.
        windowWillCloseObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                guard let self,
                      let closing = notification.object as? NSWindow,
                      self.isUserFacingWindow(closing) else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.updateActivationPolicyForVisibleWindows(excluding: closing)
                }
            }
        }

        // Keep app visible on startup: show Dock icon and bring the main window
        // to front once SwiftUI has finished creating WindowGroup windows.
        Task { @MainActor [weak self] in
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)

            if let mainWindow = NSApp.windows.first(where: { self?.isMainWindow($0) == true }) {
                mainWindow.makeKeyAndOrderFront(nil)
            }

            self?.isLaunching = false
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        environment.coordinator.checkIfBreakNeeded()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
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
