import SwiftUI

struct MorningBreakView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var todoTitles: [String] = [""]

    private var coordinator: MorningBreakCoordinator { env.coordinator }
    private var snoozeMinutes: Int { env.settings.snoozeMinutes }

    private var canConfirm: Bool {
        todoTitles.contains { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 6) {
                Text("morning_greeting")
                    .font(.title2.bold())
                Text("morning_question")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            MorningBreakTodoInputView(titles: $todoTitles)

            Divider()

            VStack(spacing: 10) {
                Button {
                    coordinator.confirm(titles: todoTitles)
                } label: {
                    Text("morning_confirm")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!canConfirm)
                .keyboardShortcut(.return, modifiers: .command)

                Button {
                    coordinator.snooze()
                    todoTitles = [""]
                } label: {
                    Text(verbatim: "Snooze · \(snoozeMinutes) min")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(32)
        .frame(width: 420)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 40, y: 12)
    }
}
