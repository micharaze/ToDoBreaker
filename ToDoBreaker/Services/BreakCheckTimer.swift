import Foundation

/// Fires a check callback every `interval` seconds on the main run loop.
/// Used instead of screen-unlock listeners — simpler and more reliable.
final class BreakCheckTimer {
    private var timer: Timer?
    private let interval: TimeInterval
    private let action: () -> Void

    init(interval: TimeInterval = 60, action: @escaping () -> Void) {
        self.interval = interval
        self.action = action
    }

    func start() {
        stop()
        let t = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            self?.action()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    deinit { stop() }
}
