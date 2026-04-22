import AppKit
import SwiftUI

/// Creates and manages full-screen overlay windows on all connected displays.
@MainActor
final class OverlayService {
    private var controllers: [OverlayWindowController] = []

    func showOverlay(morningBreakView: AnyView) {
        guard controllers.isEmpty else { return }

        let screens = NSScreen.screens
        guard !screens.isEmpty else { return }

        // Block menu bar, dock, and app switcher while overlay is visible.
        NSApp.presentationOptions = [.disableHideApplication, .hideMenuBar, .hideDock]

        for (index, screen) in screens.enumerated() {
            let isMain = (index == 0)
            let ctrl = OverlayWindowController(
                screen: screen,
                isMain: isMain,
                morningBreakView: isMain ? morningBreakView : nil
            )
            controllers.append(ctrl)
            ctrl.showWindow(nil)
        }

        // Observe display changes while overlay is active.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    func hideOverlay() {
        NSApp.presentationOptions = []
        controllers.forEach { $0.close() }
        controllers = []
        NotificationCenter.default.removeObserver(self,
            name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }

    @objc private func screensChanged() {
        // Overlay is rebuilt by AppEnvironment when isOverlayVisible stays true.
        // No action needed here — the coordinator will re-trigger on next check.
    }
}
