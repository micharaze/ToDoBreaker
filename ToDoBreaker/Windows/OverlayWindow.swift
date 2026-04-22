import AppKit

/// Full-screen, screen-saver-level window that covers one display.
final class OverlayWindow: NSWindow {
    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        level = .screenSaver
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        isOpaque = false
        backgroundColor = .clear
        ignoresMouseEvents = false
        canHide = false
        isMovable = false
        hasShadow = false
        setFrame(screen.frame, display: false)
    }

    // Swallow keyboard events so they don't reach other apps.
    // Cmd+Opt+Esc (force quit) is handled at the system level and is not affected.
    override func keyDown(with event: NSEvent) {}
    override func keyUp(with event: NSEvent) {}

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
