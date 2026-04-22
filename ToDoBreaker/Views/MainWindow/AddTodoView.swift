import SwiftUI

/// Persistent input field at the bottom of the main window for adding todos.
struct AddTodoView: View {
    @EnvironmentObject private var env: AppEnvironment
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Button {
                if env.newTodoTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                    isFocused = true
                } else {
                    env.addTodo()
                }
            } label: {
                Image(systemName: "plus.circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            TextField("Neue Aufgabe...", text: $env.newTodoTitle)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .frame(maxWidth: .infinity)
                .onSubmit { env.addTodo() }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
    }
}
