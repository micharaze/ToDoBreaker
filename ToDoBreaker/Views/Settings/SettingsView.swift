import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var settings: AppSettings = .defaults

    // Weekdays in display order (Mon first)
    private let weekdays: [(Int, String)] = [
        (2, "Mo"), (3, "Di"), (4, "Mi"), (5, "Do"), (6, "Fr"), (7, "Sa"), (1, "So")
    ]

    var body: some View {
        Form {
            Section("Morning Break") {
                LabeledContent("Startuhrzeit") {
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

                LabeledContent("Aktive Tage") {
                    HStack(spacing: 6) {
                        ForEach(weekdays, id: \.0) { weekday, name in
                            WeekdayButton(
                                label: name,
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
                Stepper(
                    "\(settings.snoozeMinutes) Minuten",
                    value: $settings.snoozeMinutes,
                    in: 1...60
                )
            }

            Section("System") {
                Toggle("Beim Anmelden starten", isOn: $settings.launchAtLogin)
                    .onChange(of: settings.launchAtLogin) { _, newValue in
                        env.loginItemService.setEnabled(newValue)
                    }

                Button("Morning Break jetzt starten") {
                    env.coordinator.triggerManually()
                }
                .disabled(env.coordinator.isOverlayVisible)
            }
        }
        .formStyle(.grouped)
        .scrollIndicators(.hidden)
        .frame(width: 420)
        .onAppear {
            settings = env.settings
            settings.launchAtLogin = env.loginItemService.isEnabled
        }
        .onChange(of: settings) { _, newSettings in
            env.saveSettings(newSettings)
        }
    }
}

private struct WeekdayButton: View {
    let label: String
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
