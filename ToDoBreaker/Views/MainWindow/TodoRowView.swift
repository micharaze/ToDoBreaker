import SwiftUI

struct TodoRowView: View {
    let todo: Todo
    var isEditMode: Bool = false
    @EnvironmentObject private var env: AppEnvironment
    @State private var isEditing = false
    @State private var editTitle = ""

    var body: some View {
        HStack(spacing: 10) {
            Button {
                env.toggleTodo(todo)
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(todo.isCompleted ? Color.accentColor : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)

            if isEditing {
                TextField("", text: $editTitle)
                    .textFieldStyle(.plain)
                    .onSubmit { commitEdit() }
                    .onExitCommand { isEditing = false }
            } else {
                Text(todo.title)
                    .strikethrough(todo.isCompleted, color: .secondary)
                    .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture(count: 2) { startEditing() }
            }

            Spacer(minLength: 0)

            if isEditMode {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        env.deleteTodo(todo)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.body)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .transition(.scale(scale: 0.7).combined(with: .opacity))
            }
        }
        .padding(.vertical, 9)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                env.deleteTodo(todo)
            } label: {
                Label("Löschen", systemImage: "trash")
            }
        }
        .contextMenu {
            Button("Bearbeiten") { startEditing() }
            Divider()
            Button("Löschen", role: .destructive) { env.deleteTodo(todo) }
        }
    }

    private func startEditing() {
        editTitle = todo.title
        isEditing = true
    }

    private func commitEdit() {
        env.updateTodoTitle(todo, newTitle: editTitle)
        isEditing = false
    }
}
