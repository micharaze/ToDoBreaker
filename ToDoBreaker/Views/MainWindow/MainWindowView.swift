import SwiftUI

struct MainWindowView: View {
    @EnvironmentObject private var env: AppEnvironment
    @State private var isEditing = false

    private var dateHeader: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "de_DE")
        f.dateFormat = "EEEE, d. MMMM"
        return f.string(from: Date())
    }

    private var completedCount: Int { env.todos.filter(\.isCompleted).count }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dateHeader)
                        .font(.headline)
                    if !env.todos.isEmpty {
                        Text("\(completedCount) von \(env.todos.count) erledigt")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if !env.todos.isEmpty {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditing.toggle()
                        }
                    } label: {
                        Image(systemName: isEditing ? "checkmark" : "pencil")
                            .font(.body.weight(.medium))
                            .foregroundStyle(isEditing ? Color.accentColor : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)
            .onChange(of: env.todos.isEmpty) { _, isEmpty in
                if isEmpty { isEditing = false }
            }

            Divider()

            // Todo list or empty state
            if env.todos.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 38))
                        .foregroundStyle(.tertiary)
                    Text("Keine Aufgaben für heute")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("Füge unten eine Aufgabe hinzu.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(env.todos) { todo in
                    TodoRowView(todo: todo, isEditMode: isEditing)
                        .listRowInsets(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                        .listRowSeparatorTint(.secondary.opacity(0.3))
                }
                .listStyle(.plain)
            }

            Divider()

            // Add todo
            AddTodoView()
                .padding(12)
        }
        .frame(minWidth: 340, idealWidth: 380, minHeight: 400, idealHeight: 520)
        .onAppear { env.loadTodaysTodos() }
    }
}
