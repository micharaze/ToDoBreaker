import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var settings: AppSettings = .defaults

    private let weekdays: [(Int, LocalizedStringKey)] = [
        (2, "weekday_mo"), (3, "weekday_tu"), (4, "weekday_we"),
        (5, "weekday_th"), (6, "weekday_fr"), (7, "weekday_sa"), (1, "weekday_su")
    ]

    var body: some View {
        Form {
            Section("Morning Break") {
                LabeledContent("settings_start_time") {
                    HStack(spacing: 4) {
                        Picker("", selection: $settings.startHour) {
                            ForEach(0..<24, id: \.self) { h in
                                Text(String(format: "%02d", h)).tag(h)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 64)

                        Text(":")
                            .foregroundStyle(.secondary)

                        Picker("", selection: $settings.startMinute) {
                            ForEach([0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55], id: \.self) { m in
                                Text(String(format: "%02d", m)).tag(m)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 64)
                    }
                }

                LabeledContent("settings_active_days") {
                    HStack(spacing: 6) {
                        ForEach(weekdays, id: \.0) { weekday, key in
                            WeekdayButton(
                                label: key,
                                isActive: settings.activeWeekdays.contains(weekday)
                            ) {
                                if settings.activeWeekdays.contains(weekday) {
                                    settings.activeWeekdays.remove(weekday)
                                } else {
                                    settings.activeWeekdays.insert(weekday)
                                }
                            }
                        }
                    }
                }
            }

            Section("Snooze") {
                Stepper(value: $settings.snoozeMinutes, in: 1...60) {
                    Text(verbatim: String(format: env.ls("settings_snooze_value"), settings.snoozeMinutes))
                }
            }

            Section("System") {
                Toggle("settings_launch_login", isOn: $settings.launchAtLogin)
                    .onChange(of: settings.launchAtLogin) { _, newValue in
                        env.loginItemService.setEnabled(newValue)
                    }

                Button("settings_start_now") {
                    env.coordinator.triggerManually()
                }
                .disabled(env.coordinator.isOverlayVisible)
            }

            Section("settings_section_language") {
                Picker("_", selection: $settings.language) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(languageLabel(lang)).tag(lang)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .fixedSize()
            }
        }
        .formStyle(.grouped)
        .scrollIndicators(.hidden)
        .frame(width: 420)
        .environment(\.locale, env.appLocale)
        .onAppear {
            settings = env.settings
            settings.launchAtLogin = env.loginItemService.isEnabled
        }
        .onChange(of: settings) { _, newSettings in
            env.saveSettings(newSettings)
        }
    }

    private func languageLabel(_ lang: AppLanguage) -> LocalizedStringKey {
        switch lang {
        case .english: return "language_english"
        case .german:  return "language_german"
        }
    }
}

private struct WeekdayButton: View {
    let label: LocalizedStringKey
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.bold())
                .frame(width: 30, height: 30)
                .background(
                    isActive ? Color.accentColor : Color.primary.opacity(0.08),
                    in: Circle()
                )
                .foregroundStyle(isActive ? .white : .secondary)
        }
        .buttonStyle(.plain)
    }
}
