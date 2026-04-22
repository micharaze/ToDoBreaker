import AppKit
import SwiftUI

/// Manages one OverlayWindow for a single display.
/// The main screen gets the blur + morning break modal.
/// Secondary screens get blur only (mouse events still blocked).
final class OverlayWindowController: NSWindowController {
    // Keep a strong reference so the hosting controller is not deallocated.
    private var hostingController: NSHostingController<AnyView>?

    init(screen: NSScreen, isMain: Bool, morningBreakView: AnyView?) {
        let win = OverlayWindow(screen: screen)
        super.init(window: win)

        let content: AnyView
        if isMain, let breakView = morningBreakView {
            content = AnyView(
                ZStack {
                    BlurOverlayView()
                    breakView
                }
            )
            win.makeKey()
        } else {
            content = AnyView(BlurOverlayView())
        }

        let hc = NSHostingController(rootView: content)
        hostingController = hc

        // Add hosting controller's view as subview filling the window content area.
        if let contentView = win.contentView {
            hc.view.frame = contentView.bounds
            hc.view.autoresizingMask = [.width, .height]
            contentView.addSubview(hc.view)
        }
    }

    required init?(coder: NSCoder) { fatalError("Not implemented") }

    override func close() {
        window?.orderOut(nil)
    }
}
