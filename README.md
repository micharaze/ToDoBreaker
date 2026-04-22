# ToDoBreaker

A minimal macOS menu bar app for ephemeral daily task planning. Every morning, a full-screen overlay blocks your displays until you've planned your day. Todos are tied to the current day and are cleared when you confirm the next morning break.

## Features

- **Morning Break overlay** — blocks all screens at a configured time until you enter your tasks for the day
- **Daily todos** — tasks are tied to the current day and cleared when the next morning break is confirmed
- **Menu bar** — shows today's progress (completed / total) and quick actions without opening the main window
- **Snooze** — postpone the morning break by a configurable number of minutes
- **Active days** — configure which weekdays the morning break is active

## Requirements

- macOS 14.0 or later
- Xcode 15 or later
- [xcodegen](https://github.com/yonaskolb/XcodeGen)

## Build

```bash
# Install xcodegen (first time only)
brew install xcodegen

# Generate the Xcode project
xcodegen generate

# Open in Xcode
open ToDoBreaker.xcodeproj
```

Then press **Cmd+R** to build and run.

## Distribution

Mac App Store distribution is not practical: Apple's review guidelines prohibit apps that block all displays and hide system UI (Dock, menu bar) — regardless of sandboxing. All APIs used are technically sandbox-compatible.

Distribute via notarized DMG or share the `.app` bundle directly. Recipients may need to right-click → Open on first launch if the app is not notarized.

## Tech Stack

- Swift + SwiftUI (macOS 14+)
- AppKit for overlay windows (`NSWindow` at `.screenSaver` level)
- [SQLite.swift](https://github.com/stephencelis/SQLite.swift) for local storage
- [xcodegen](https://github.com/yonaskolb/XcodeGen) for project generation
