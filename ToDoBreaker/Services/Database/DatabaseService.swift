import Foundation
import SQLite

/// Manages the SQLite connection and runs schema migrations.
final class DatabaseService {
    static let shared = DatabaseService()

    private(set) var connection: Connection?

    /// Serial queue for all database operations. Never dispatch back to main from this queue.
    let queue = DispatchQueue(label: "de.radzieda.ToDoBreaker.database", qos: .utility)

    private init() {
        queue.sync { self.setup() }
    }

    private func setup() {
        do {
            let dir = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("ToDoBreaker", isDirectory: true)

            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

            let db = try Connection(dir.appendingPathComponent("todos.db").path)
            db.busyTimeout = 5
            try migrate(db)
            connection = db
        } catch {
            print("[DatabaseService] Setup failed: \(error)")
        }
    }

    private func migrate(_ db: Connection) throws {
        try db.execute("""
            CREATE TABLE IF NOT EXISTS todos (
                id           TEXT PRIMARY KEY,
                title        TEXT NOT NULL,
                created_at   REAL NOT NULL,
                completed_at REAL,
                is_completed INTEGER NOT NULL DEFAULT 0,
                day_key      TEXT NOT NULL
            );
            CREATE INDEX IF NOT EXISTS idx_todos_day_key ON todos(day_key);
            CREATE TABLE IF NOT EXISTS settings (
                key   TEXT PRIMARY KEY,
                value TEXT NOT NULL
            );
        """)
    }
}
