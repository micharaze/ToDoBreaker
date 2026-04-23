import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english, german

    var id: String { rawValue }

    var locale: Locale {
        switch self {
        case .english: return Locale(identifier: "en")
        case .german:  return Locale(identifier: "de")
        }
    }
}

struct AppSettings: Equatable {
    var startHour: Int
    var startMinute: Int
    var snoozeMinutes: Int
    /// Active weekdays using Calendar.current conventions: 1=Sun, 2=Mon … 7=Sat
    var activeWeekdays: Set<Int>
    var launchAtLogin: Bool
    var language: AppLanguage

    static var defaults: AppSettings {
        let systemLang = Locale.current.language.languageCode?.identifier
        return AppSettings(
            startHour: 6,
            startMinute: 0,
            snoozeMinutes: 5,
            activeWeekdays: [2, 3, 4, 5, 6],
            launchAtLogin: false,
            language: systemLang == "de" ? .german : .english
        )
    }
}
