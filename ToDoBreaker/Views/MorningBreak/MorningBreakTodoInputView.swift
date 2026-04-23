import SwiftUI

struct MorningBreakTodoInputView: View {
    @Binding var titles: [String]
    @FocusState private var focusedID: UUID?

    private struct Entry: Identifiable {
        let id = UUID()
        var title: String
    }

    @State private var entries: [Entry] = []

    var body: some View {
        VStack(spacing: 6) {
            ForEach(entries) { entry in
                HStack(spacing: 10) {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                        .font(.body)
                        .frame(width: 18)

                    TextField("Aufgabe eingeben...", text: safeBinding(for: entry.id))
                        .textFieldStyle(.plain)
                        .font(.body)
                        .focused($focusedID, equals: entry.id)
                        .onSubmit { appendField() }

                    if entries.count > 1 {
                        Button {
                            removeField(id: entry.id)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 8))
            }

            Button {
                appendField()
            } label: {
                Label("Weitere Aufgabe", systemImage: "plus")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .onAppear {
            entries = titles.map { Entry(title: $0) }
            focusedID = entries.first?.id
        }
        .onChange(of: entries.map(\.title)) { _, newTitles in
            titles = newTitles
        }
    }

    private func safeBinding(for id: UUID) -> Binding<String> {
        Binding(
            get: { entries.first(where: { $0.id == id })?.title ?? "" },
            set: { newValue in
                guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
                entries[index].title = newValue
            }
        )
    }

    private func appendField() {
        let entry = Entry(title: "")
        entries.append(entry)
        DispatchQueue.main.async { focusedID = entry.id }
    }

    private func removeField(id: UUID) {
        guard entries.count > 1 else { return }
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        entries.remove(at: index)
        focusedID = entries[max(0, index - 1)].id
    }
}
