import Foundation
import SQLite

final class TodoRepository {
    private let db: DatabaseService

    private let table        = Table("todos")
    private let colId        = Expression<String>("id")
    private let colTitle     = Expression<String>("title")
    private let colCreatedAt = Expression<Double>("created_at")
    private let colCompletedAt = Expression<Double?>("completed_at")
    private let colIsCompleted = Expression<Int>("is_completed")
    private let colDayKey    = Expression<String>("day_key")

    init(db: DatabaseService = .shared) {
        self.db = db
    }

    // MARK: - Reads (synchronous – called from main thread, must be fast)

    func fetchTodos(forDayKey dayKey: String) -> [Todo] {
        var result: [Todo] = []
        db.queue.sync {
            guard let conn = db.connection else { return }
            do {
                let query = table.filter(colDayKey == dayKey).order(colCreatedAt.asc)
                result = try conn.prepare(query).map { self.row(to: $0) }
            } catch {
                print("[TodoRepository] fetchTodos: \(error)")
            }
        }
        return result
    }

    // MARK: - Writes (async unless called from confirmMorningBreak)

    func insert(_ todo: Todo) {
        db.queue.async {
            guard let conn = self.db.connection else { return }
            do {
                try conn.run(self.table.insert(or: .replace,
                    self.colId          <- todo.id.uuidString,
                    self.colTitle       <- todo.title,
                    self.colCreatedAt   <- todo.createdAt.timeIntervalSince1970,
                    self.colCompletedAt <- todo.completedAt?.timeIntervalSince1970,
                    self.colIsCompleted <- todo.isCompleted ? 1 : 0,
                    self.colDayKey      <- todo.dayKey
                ))
            } catch {
                print("[TodoRepository] insert: \(error)")
            }
        }
    }

    func update(_ todo: Todo) {
        db.queue.async {
            guard let conn = self.db.connection else { return }
            do {
                let row = self.table.filter(self.colId == todo.id.uuidString)
                try conn.run(row.update(
                    self.colTitle       <- todo.title,
                    self.colCompletedAt <- todo.completedAt?.timeIntervalSince1970,
                    self.colIsCompleted <- todo.isCompleted ? 1 : 0
                ))
            } catch {
                print("[TodoRepository] update: \(error)")
            }
        }
    }

    func delete(id: UUID) {
        db.queue.async {
            guard let conn = self.db.connection else { return }
            do {
                try conn.run(self.table.filter(self.colId == id.uuidString).delete())
            } catch {
                print("[TodoRepository] delete: \(error)")
            }
        }
    }

    /// Atomically deletes all previous-day todos and inserts the new ones.
    /// Runs synchronously so the caller can immediately read the updated state.
    func confirmMorningBreak(titles: [String], dayKey: String) {
        db.queue.sync {
            guard let conn = self.db.connection else { return }
            do {
                try conn.transaction {
                    try conn.run(self.table.filter(self.colDayKey != dayKey).delete())
                    for title in titles {
                        try conn.run(self.table.insert(
                            self.colId          <- UUID().uuidString,
                            self.colTitle       <- title,
                            self.colCreatedAt   <- Date().timeIntervalSince1970,
                            self.colCompletedAt <- nil,
                            self.colIsCompleted <- 0,
                            self.colDayKey      <- dayKey
                        ))
                    }
                }
            } catch {
                print("[TodoRepository] confirmMorningBreak: \(error)")
            }
        }
    }

    // MARK: - Private

    private func row(to row: Row) -> Todo {
        Todo(
            id: UUID(uuidString: row[colId]) ?? UUID(),
            title: row[colTitle],
            createdAt: Date(timeIntervalSince1970: row[colCreatedAt]),
            completedAt: row[colCompletedAt].map { Date(timeIntervalSince1970: $0) },
            isCompleted: row[colIsCompleted] == 1,
            dayKey: row[colDayKey]
        )
    }
}
