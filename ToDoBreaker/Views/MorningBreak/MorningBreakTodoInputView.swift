import SwiftUI

/// Dynamic list of text fields for entering today's todos during the morning break.
struct MorningBreakTodoInputView: View {
    @Binding var titles: [String]
    @FocusState private var focusedIndex: Int?

    var body: some View {
        VStack(spacing: 6) {
            ForEach(Array(titles.enumerated()), id: \.offset) { index, _ in
                HStack(spacing: 10) {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                        .font(.body)
                        .frame(width: 18)

                    TextField("Aufgabe eingeben...", text: $titles[index])
                        .textFieldStyle(.plain)
                        .font(.body)
                        .focused($focusedIndex, equals: index)
                        .onSubmit { appendField() }

                    if titles.count > 1 {
                        Button {
                            removeField(at: index)
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
        .onAppear { focusedIndex = 0 }
    }

    private func appendField() {
        titles.append("")
        let newIndex = titles.count - 1
        // Give SwiftUI a tick to render the new field before focusing it.
        DispatchQueue.main.async { focusedIndex = newIndex }
    }

    private func removeField(at index: Int) {
        guard titles.count > 1 else { return }
        titles.remove(at: index)
        focusedIndex = max(0, index - 1)
    }
}
