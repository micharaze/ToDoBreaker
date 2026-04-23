import Foundation
import SQLite

/// Key-value store for app settings and break state, backed by SQLite.
final class SettingsRepository {
    private let db: DatabaseService
    private let table    = Table("settings")
    private let colKey   = Expression<String>("key")
    private let colValue = Expression<String>("value")

    init(db: DatabaseService = .shared) {
        self.db = db
    }

    // MARK: - Generic (synchronous read, async write)

    private func get(_ key: String) -> String? {
        var result: String?
        db.queue.sync {
            guard let conn = db.connection else { return }
            result = try? conn.pluck(table.filter(colKey == key)).flatMap { $0[colValue] }
        }
        return result
    }

    private func set(_ key: String, value: String) {
        db.queue.async {
            guard let conn = self.db.connection else { return }
            _ = try? conn.run(self.table.insert(or: .replace,
                self.colKey   <- key,
                self.colValue <- value
            ))
        }
    }

    private func remove(_ key: String) {
        db.queue.async {
            guard let conn = self.db.connection else { return }
            _ = try? conn.run(self.table.filter(self.colKey == key).delete())
        }
    }

    // MARK: - AppSettings

    func loadSettings() -> AppSettings {
        var s = AppSettings.defaults
        if let h = get("start_hour").flatMap(Int.init)    { s.startHour = h }
        if let m = get("start_minute").flatMap(Int.init)  { s.startMinute = m }
        if let n = get("snooze_minutes").flatMap(Int.init) { s.snoozeMinutes = n }
        if let days = get("active_weekdays"), !days.isEmpty {
            s.activeWeekdays = Set(days.split(separator: ",").compactMap { Int($0) })
        }
        if let v = get("launch_at_login") { s.launchAtLogin = v == "true" }
        if let lang = get("language").flatMap(AppLanguage.init(rawValue:)) { s.language = lang }
        return s
    }

    func saveSettings(_ settings: AppSettings) {
        set("start_hour",      value: "\(settings.startHour)")
        set("start_minute",    value: "\(settings.startMinute)")
        set("snooze_minutes",  value: "\(settings.snoozeMinutes)")
        set("active_weekdays", value: settings.activeWeekdays.sorted().map(String.init).joined(separator: ","))
        set("launch_at_login", value: settings.launchAtLogin ? "true" : "false")
        set("language",        value: settings.language.rawValue)
    }

    // MARK: - Break state

    func breakDoneDate() -> String? {
        get("break_done_date")
    }

    func setBreakDoneDate(_ dayKey: String) {
        set("break_done_date", value: dayKey)
    }

    // MARK: - Snooze

    func snoozeUntil() -> Date? {
        get("snooze_until").flatMap(Double.init).map { Date(timeIntervalSince1970: $0) }
    }

    func setSnoozeUntil(_ date: Date?) {
        if let date {
            set("snooze_until", value: "\(date.timeIntervalSince1970)")
        } else {
            remove("snooze_until")
        }
    }
}
