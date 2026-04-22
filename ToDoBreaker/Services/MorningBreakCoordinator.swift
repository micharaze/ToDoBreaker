import Foundation
import Combine

/// Owns the Morning Break state machine.
/// `isOverlayVisible` drives the overlay via AppEnvironment's Combine subscription.
@MainActor
final class MorningBreakCoordinator: ObservableObject {
    @Published private(set) var isOverlayVisible = false

    private let todoRepo: TodoRepository
    private let settingsRepo: SettingsRepository
    private var settings: AppSettings
    private var checkTimer: BreakCheckTimer?

    init(todoRepo: TodoRepository, settingsRepo: SettingsRepository, settings: AppSettings) {
        self.todoRepo = todoRepo
        self.settingsRepo = settingsRepo
        self.settings = settings
    }

    // MARK: - Timer

    func startTimer() {
        checkTimer = BreakCheckTimer(interval: 60) { [weak self] in
            Task { @MainActor in self?.checkIfBreakNeeded() }
        }
        checkTimer?.start()
    }

    // MARK: - Public API

    func updateSettings(_ settings: AppSettings) {
        self.settings = settings
    }

    /// Called by the timer, wake notification, and on app launch/activate.
    func checkIfBreakNeeded() {
        guard !isOverlayVisible else { return }
        guard isActiveWeekday() else { return }
        guard isPastStartTime() else { return }
        guard !isBreakDoneToday() else { return }
        guard !isSnoozed() else { return }
        isOverlayVisible = true
    }

    /// User confirmed todos. Writes to DB synchronously then hides overlay.
    func confirm(titles: [String]) {
        let today = todayKey()
        let valid = titles.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        todoRepo.confirmMorningBreak(titles: valid, dayKey: today)
        settingsRepo.setBreakDoneDate(today)
        settingsRepo.setSnoozeUntil(nil)
        isOverlayVisible = false
    }

    /// User snoozed. Hides overlay, re-check after configured minutes.
    func snooze() {
        let until = Date().addingTimeInterval(Double(settings.snoozeMinutes) * 60)
        settingsRepo.setSnoozeUntil(until)
        isOverlayVisible = false
    }

    /// Manually trigger the break from the menu bar.
    func triggerManually() {
        guard !isOverlayVisible else { return }
        isOverlayVisible = true
    }

    // MARK: - Day key

    /// Returns "YYYY-MM-DD" for the effective day, adjusted for the configured start time.
    /// Before `startHour:startMinute` the effective day is still yesterday.
    func todayKey(for date: Date = .now) -> String {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.hour, .minute, .day, .month, .year], from: date)
        let currentMinutes = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
        let startMinutes = settings.startHour * 60 + settings.startMinute

        let effectiveDate: Date
        if currentMinutes < startMinutes {
            effectiveDate = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        } else {
            effectiveDate = date
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: effectiveDate)
    }

    // MARK: - Conditions

    private func isActiveWeekday() -> Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return settings.activeWeekdays.contains(weekday)
    }

    private func isPastStartTime() -> Bool {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let current = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
        let start   = settings.startHour * 60 + settings.startMinute
        return current >= start
    }

    private func isBreakDoneToday() -> Bool {
        settingsRepo.breakDoneDate() == todayKey()
    }

    private func isSnoozed() -> Bool {
        guard let until = settingsRepo.snoozeUntil() else { return false }
        return Date() < until
    }
}
