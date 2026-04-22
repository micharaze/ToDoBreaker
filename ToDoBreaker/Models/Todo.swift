import Foundation

struct Todo: Identifiable, Equatable {
    let id: UUID
    var title: String
    let createdAt: Date
    var completedAt: Date?
    var isCompleted: Bool
    let dayKey: String  // "YYYY-MM-DD" adjusted for configured start time

    init(
        id: UUID = UUID(),
        title: String,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        isCompleted: Bool = false,
        dayKey: String
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.isCompleted = isCompleted
        self.dayKey = dayKey
    }
}
