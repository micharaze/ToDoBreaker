import Foundation
import SwiftUI
import Combine

/// Single source of truth for all app state.
/// Passed as @EnvironmentObject through the entire view hierarchy.
@MainActor
final class AppEnvironment: ObservableObject {
    // MARK: - Services
    let todoRepo: TodoRepository
    let settingsRepo: SettingsRepository
    let overlayService: OverlayService
    let coordinator: MorningBreakCoordinator
    let loginItemService: LoginItemService

    // MARK: - Published state
    @Published var todos: [Todo] = []
    @Published var newTodoTitle: String = ""
    @Published var settings: AppSettings

    private var cancellables = Set<AnyCancellable>()

    init() {
        let db = DatabaseService.shared
        let todoRepo = TodoRepository(db: db)
        let settingsRepo = SettingsRepository(db: db)
        let settings = settingsRepo.loadSettings()

        self.todoRepo = todoRepo
        self.settingsRepo = settingsRepo
        self.overlayService = OverlayService()
        self.loginItemService = LoginItemService.shared
        self.settings = settings
        self.coordinator = MorningBreakCoordinator(
            todoRepo: todoRepo,
            settingsRepo: settingsRepo,
            settings: settings
        )

        setupBindings()
    }

    private func setupBindings() {
        // Forward coordinator changes so views observing env also react.
        coordinator.objectWillChange
            .sink { [weak self] in self?.objectWillChange.send() }
            .store(in: &cancellables)

        // Wire coordinator's overlay flag to the overlay service.
        coordinator.$isOverlayVisible
            .receive(on: RunLoop.main)
            .sink { [weak self] visible in
                guard let self else { return }
                if visible {
                    let view = AnyView(MorningBreakView().environmentObject(self))
                    overlayService.showOverlay(morningBreakView: view)
                } else {
                    overlayService.hideOverlay()
                    // Reload todos after morning break is confirmed.
                    loadTodaysTodos()
                }
            }
            .store(in: &cancellables)

        // Persist settings changes and keep coordinator in sync.
        $settings
            .dropFirst()
            .sink { [weak self] newSettings in
                self?.coordinator.updateSettings(newSettings)
                self?.settingsRepo.saveSettings(newSettings)
            }
            .store(in: &cancellables)
    }

    // MARK: - Todo operations

    func loadTodaysTodos() {
        todos = todoRepo.fetchTodos(forDayKey: coordinator.todayKey())
            .sorted { !$0.isCompleted && $1.isCompleted }
    }

    func addTodo() {
        let title = newTodoTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        todoRepo.insert(Todo(title: title, dayKey: coordinator.todayKey()))
        newTodoTitle = ""
        withAnimation(.easeOut(duration: 0.3)) {
            loadTodaysTodos()
        }
    }

    func toggleTodo(_ todo: Todo) {
        var updated = todo
        updated.isCompleted.toggle()
        updated.completedAt = updated.isCompleted ? Date() : nil
        todoRepo.update(updated)

        // Update checkmark in place immediately, without re-sorting.
        if let idx = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[idx] = updated
        }

        withAnimation(.easeInOut(duration: 0.35)) {
            loadTodaysTodos()
        }
    }

    func deleteTodo(_ todo: Todo) {
        todoRepo.delete(id: todo.id)
        loadTodaysTodos()
    }

    func updateTodoTitle(_ todo: Todo, newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        var updated = todo
        updated.title = trimmed
        todoRepo.update(updated)
        loadTodaysTodos()
    }

    // MARK: - Settings

    func saveSettings(_ newSettings: AppSettings) {
        settings = newSettings
    }
}
