# ToDoBreaker — Project Instructions

## Overview
A macOS native Swift/SwiftUI app for ephemeral daily task planning. Todos expire daily.
A "Morning Break" overlay blocks all screens at a configured time until the user plans their day.

## Stack
- Swift + SwiftUI (macOS 13.0+)
- AppKit hybrid for overlay windows (NSWindow with `.screenSaver` level)
- SQLite.swift for local storage (`~/Library/Application Support/ToDoBreaker/todos.db`)
- Swift Package Manager (managed via xcodegen + `project.yml`)
- **No App Sandbox** — required for screen-level NSWindow and wake notifications

## Project Structure
```
ToDoBreaker/
├── App/               — ToDoBreakerApp, AppDelegate, AppEnvironment (DI container)
├── Models/            — Todo, AppSettings structs
├── Services/
│   ├── Database/      — DatabaseService, TodoRepository, SettingsRepository
│   ├── MorningBreakCoordinator.swift
│   ├── OverlayService.swift
│   ├── BreakCheckTimer.swift
│   └── LoginItemService.swift
├── Windows/           — OverlayWindow, OverlayWindowController (AppKit)
└── Views/
    ├── MainWindow/    — MainWindowView, TodoRowView, AddTodoView
    ├── MorningBreak/  — MorningBreakView, MorningBreakTodoInputView, BlurOverlayView
    ├── Settings/      — SettingsView
    └── MenuBar/       — MenuBarContentView
```

## Key Architecture Decisions
- **AppEnvironment** — single `ObservableObject` DI container, passed as `@EnvironmentObject`
- **MorningBreakCoordinator** — owns break state machine, publishes `isOverlayVisible: Bool`
- **BreakCheckTimer** — 60s background timer (NOT a screen-unlock listener) triggers checks
- **OverlayService** — one NSWindow per NSScreen at `.screenSaver` level + `canJoinAllSpaces`
- **DB location** — `~/Library/Application Support/ToDoBreaker/todos.db`
- **todayKey** — "YYYY-MM-DD" adjusted for configured start time (before start hour = yesterday)

## Build
```bash
# Install xcodegen (first time only)
brew install xcodegen

# Generate Xcode project (run from repo root)
xcodegen generate

# Open in Xcode
open ToDoBreaker.xcodeproj
```

## Database Schema
```sql
todos: id TEXT, title TEXT, created_at REAL, completed_at REAL, is_completed INTEGER, day_key TEXT
settings: key TEXT, value TEXT
-- Setting keys: start_hour, start_minute, snooze_minutes, active_weekdays,
--               break_done_date, snooze_until, launch_at_login
```

## Testing Morning Break
1. Set start time to current hour in Settings
2. Click "Morning Break starten" in menu bar
3. All displays should blur, modal appears

## Distribution
App is NOT sandboxed → Mac App Store distribution not possible.
Distribute via notarized DMG.
