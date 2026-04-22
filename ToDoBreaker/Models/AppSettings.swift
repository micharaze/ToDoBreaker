import Foundation

struct AppSettings: Equatable {
    /// Hour at which a new "day" begins (0–23)
    var startHour: Int
    /// Minute at which a new "day" begins (0–59)
    var startMinute: Int
    /// How many minutes to snooze the morning break
    var snoozeMinutes: Int
    /// Active weekdays using Calendar.current conventions: 1=Sun, 2=Mon … 7=Sat
    var activeWeekdays: Set<Int>
    /// Whether the app should launch at login
    var launchAtLogin: Bool

    static let defaults = AppSettings(
        startHour: 6,
        startMinute: 0,
        snoozeMinutes: 5,
        activeWeekdays: [2, 3, 4, 5, 6],  // Mon–Fri
        launchAtLogin: false
    )

    /// Short display name for a weekday integer (Calendar convention).
    static func weekdayName(_ weekday: Int) -> String {
        let names = ["", "So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"]
        guard weekday >= 1, weekday <= 7 else { return "" }
        return names[weekday]
    }
}
